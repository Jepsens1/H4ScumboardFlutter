import 'dart:convert';

import 'package:boardview/board_item.dart';
import 'package:boardview/board_list.dart';
import 'package:boardview/boardview.dart';
import 'package:boardview/boardview_controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:my_app/BoardListObject.dart';

class ScrumBoard extends StatefulWidget {
  const ScrumBoard({super.key});
  @override
  State<ScrumBoard> createState() => _ScrumBoardState();
}

class _ScrumBoardState extends State<ScrumBoard> {
  List<BoardPostColumn> data = [];

  late BoardViewController boardViewController;
  late TextEditingController textEditingController;
  Future<List<BoardPostColumn>> GetData() async {
    if (data.isEmpty) {
      Response response = await get(
          Uri.parse('https://localhost:7252/api/ScrumTask/GetScrumTasks'));
      if (response.statusCode == 200) {
        return parseJsonToList(response.body);
      } else {
        throw Exception('Failed to load');
      }
    }
    return data;
  }

  void _RemoveTask(int? index) async {
    Response response = await delete(Uri.parse(
        'https://localhost:7252/api/ScrumTask/DeleteScrumTask?id=$index'));
    if (response.statusCode == 200) {
      setState(() {
        for (var i = 0; i < data.length; i++) {
          data[i].items.removeWhere((e) => e.id == index);
        }
      });
      print(response.body);
    } else {
      throw Exception('Failed to delete');
    }
  }

  List<BoardPostColumn> parseJsonToList(String responseBody) {
    List<BoardPost> tasks = (json.decode(responseBody) as List)
        .map((data) => BoardPost.fromJson(data))
        .toList();
    data.add(BoardPostColumn(
        title: 'To do',
        items: tasks
            .where((e) => e.taskState?.toLowerCase() == 'todo'.toLowerCase())
            .toList()));
    data.add(BoardPostColumn(
        title: 'In Progress',
        items: tasks
            .where((e) =>
                e.taskState?.toLowerCase() == 'in progress'.toLowerCase())
            .toList()));
    data.add(BoardPostColumn(
        title: 'Done',
        items: tasks
            .where((e) => e.taskState?.toLowerCase() == 'done'.toLowerCase())
            .toList()));
    return data;
  }

  @override
  void initState() {
    super.initState();
    boardViewController = BoardViewController();
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<BoardList> _lists = [];

    return Container(
      child: FutureBuilder(
          future: GetData(),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              for (var element in snapshot.data!) {
                _lists.add(CreateBoardList(element, context));
              }
            }
            return BoardView(
              lists: _lists,
              boardViewController: boardViewController,
            );
          })),
    );
  }

  ///Creates a [BoardList] with drag n drop functionality
  BoardList CreateBoardList(BoardPostColumn list, BuildContext context) {
    List<BoardItem> items = [];
    for (int i = 0; i < list.items.length; i++) {
      items.insert(i, buildBoardItem(list.items[i], context));
    }

    return BoardList(
      onStartDragList: (int? listIndex) {},
      //OnTap for each individual task, open an edit dialog box
      onTapList: (int? listIndex) async {},
      onDropList: (int? listIndex, int? oldListIndex) {
        //Update our local list data
        var list = data[oldListIndex!];
        data.removeAt(oldListIndex);
        data.insert(listIndex!, list);
      },
      headerBackgroundColor: Color(0xFFEBECF0),
      backgroundColor: Color(0xFFEBECF0),
      header: [
        Expanded(
            child: Padding(
                padding: EdgeInsets.all(5),
                child: Text(
                  list.title,
                  style: TextStyle(fontSize: 20),
                ))),
      ],
      items: items,
    );
  }

  ///Creates each individuel [BoardItem] of time [BoardPost] that will be used in the [BoardList]
  BoardItem buildBoardItem(BoardPost itemObject, BuildContext context) {
    return BoardItem(
        onStartDragItem:
            (int? listIndex, int? itemIndex, BoardItemState? state) {},
        onDropItem: (int? listIndex, int? itemIndex, int? oldListIndex,
            int? oldItemIndex, BoardItemState? state) {
          //Used to update our local item data
          var item = data[oldListIndex!].items[oldItemIndex!];
          data[oldListIndex].items.removeAt(oldItemIndex);
          data[listIndex!].items.insert(itemIndex!, item);
        },
        //Holder for tasks, use ontap to rename the thingy
        onTapItem:
            (int? listIndex, int? itemIndex, BoardItemState? state) async {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(data[listIndex!].items[itemIndex!].taskName!),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: [
                        Text('Task ID: ${data[listIndex].items[itemIndex].id}'),
                        Text(
                            'Task Name: ${data[listIndex].items[itemIndex].taskName}'),
                        Text(
                            'Task Description: ${data[listIndex].items[itemIndex].taskDescription}'),
                        Text(
                            'Story Points: ${data[listIndex].items[itemIndex].storyPoints}'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: Text("Delete"),
                      onPressed: () {
                        _RemoveTask(data[listIndex].items[itemIndex].id);
                      },
                    ),
                    TextButton(
                      child: Text('Change'),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: ((context) {
                              return AlertDialog(
                                title: Text(
                                    '${data[listIndex].items[itemIndex].taskName}'),
                              );
                            }));
                      },
                    ),
                  ],
                );
              });
        },
        item: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(itemObject.taskName!),
          ),
        ));
  }
}
