import 'package:boardview/board_item.dart';
import 'package:boardview/board_list.dart';
import 'package:boardview/boardview.dart';
import 'package:boardview/boardview_controller.dart';
import 'package:flutter/material.dart';
import 'package:my_app/BoardListObject.dart';
import 'package:my_app/screens/ScrumTaskManager.dart';

class ScrumBoard extends StatefulWidget {
  const ScrumBoard({super.key});
  @override
  State<ScrumBoard> createState() => _ScrumBoardState();
}

class _ScrumBoardState extends State<ScrumBoard> {
  late ScrumTaskManager manager;
  List<BoardPostColumn> data = [];
  final _formKey = GlobalKey<FormState>();
  final List<String> states = ['Todo', 'In Progress', 'Done'];

  late BoardViewController boardViewController;
  final List<TextEditingController> textscontrollers =
      List.generate(3, (i) => TextEditingController());

  Future<List<BoardPostColumn>> GetData() async {
    if (data.isEmpty) {
      data = await manager.GetData();
    }
    return data;
  }

  void _RemoveTask(int? index) async {
    if (await manager.RemoveTask(index)) {
      setState(() {
        for (var i = 0; i < data.length; i++) {
          data[i].items.removeWhere((e) => e.id == index);
        }
      });
    } else {
      throw Exception('Failed to delete');
    }
  }

  void _UpdateTask(BoardPost task) async {
    task.taskName = textscontrollers[0].text;
    task.taskDescription = textscontrollers[1].text;
    task.storyPoints = int.parse(textscontrollers[2].text);
    BoardPost result = await manager.UpdateTask(task);
    setState(() {
      task = result;
      textscontrollers[0].clear();
      textscontrollers[1].clear();
      textscontrollers[2].clear();
    });
  }

  void _AddTask(String? state) async {
    BoardPost task = BoardPost();
    task.taskName = textscontrollers[0].text;
    task.taskDescription = textscontrollers[1].text;
    task.storyPoints = int.parse(textscontrollers[2].text);
    task.taskState = state;
    var result = await manager.CreateTask(task);
    if (result.taskState?.toLowerCase() == "todo") {
      setState(() {
        textscontrollers[0].clear();
        textscontrollers[1].clear();
        textscontrollers[2].clear();
        data[0].items.add(result);
      });
    }
    if (result.taskState?.toLowerCase() == "in progress") {
      setState(() {
        textscontrollers[0].clear();
        textscontrollers[1].clear();
        textscontrollers[2].clear();
        data[1].items.add(result);
      });
    }
    if (result.taskState?.toLowerCase() == "done") {
      setState(() {
        textscontrollers[0].clear();
        textscontrollers[1].clear();
        textscontrollers[2].clear();
        data[2].items.add(result);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    boardViewController = BoardViewController();
    manager = ScrumTaskManager();
  }

  @override
  void dispose() {
    super.dispose();
    for (var i = 0; i < textscontrollers.length; i++) {
      textscontrollers[i].dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: GetData(),
          builder: ((context, snapshot) {
            List<BoardList> _lists = [];
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                String stateselected = states.first;
                return AlertDialog(
                  title: Text('Add new Task'),
                  content: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text('Task Name'),
                        TextFormField(
                          controller: textscontrollers[0],
                          decoration: InputDecoration(
                            hintText: 'Name of task',
                          ),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Task name cant be empty';
                            }
                            return null;
                          },
                        ),
                        Text('Task Description'),
                        TextFormField(
                          controller: textscontrollers[1],
                          decoration: const InputDecoration(
                            hintText: 'Description text',
                          ),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Task Description cant be empty';
                            }
                            return null;
                          },
                        ),
                        Text('Story Points'),
                        TextFormField(
                          controller: textscontrollers[2],
                          decoration: InputDecoration(
                            hintText: '0',
                          ),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Story Points cant be empty';
                            }
                            return null;
                          },
                        ),
                        Text('Task State'),
                        DropdownButton<String>(
                          value: stateselected,
                          icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          style: const TextStyle(
                            color: Colors.blue,
                          ),
                          underline: Container(
                            height: 2,
                            color: Colors.blue,
                          ),
                          onChanged: (String? value) {
                            setState(() {
                              stateselected = value!;
                            });
                          },
                          items: states
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        ElevatedButton(
                          child: Text('Add Task'),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _AddTask(stateselected);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Added Task')));
                            }
                          },
                        )
                      ],
                    ),
                  ),
                );
              });
        },
        backgroundColor: Colors.blue,
        label: const Text('Add Task'),
        icon: const Icon(Icons.add),
      ),
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
          //item.state;
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
                        Text(
                            'Task State: ${data[listIndex].items[itemIndex].taskState}'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: Text("Delete"),
                      onPressed: () {
                        _RemoveTask(data[listIndex].items[itemIndex].id);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Deleted Task')));
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child: Text('Change'),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: ((context) {
                              return AlertDialog(
                                title: Text('Task Informations'),
                                content: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      Text('Task Name'),
                                      TextFormField(
                                        controller: textscontrollers[0],
                                        decoration: InputDecoration(
                                          hintText: data[listIndex]
                                              .items[itemIndex]
                                              .taskName,
                                        ),
                                        validator: (text) {
                                          if (text == null || text.isEmpty) {
                                            return 'Task Name cant be empty';
                                          }
                                          return null;
                                        },
                                      ),
                                      Text('Task Description'),
                                      TextFormField(
                                        controller: textscontrollers[1],
                                        decoration: InputDecoration(
                                          hintText: data[listIndex]
                                              .items[itemIndex]
                                              .taskDescription,
                                        ),
                                        validator: (text) {
                                          if (text == null || text.isEmpty) {
                                            return 'Task Description cant be empty';
                                          }
                                          return null;
                                        },
                                      ),
                                      Text('Story Points'),
                                      TextFormField(
                                        controller: textscontrollers[2],
                                        decoration: InputDecoration(
                                          hintText: data[listIndex]
                                              .items[itemIndex]
                                              .storyPoints
                                              .toString(),
                                        ),
                                        validator: (text) {
                                          if (text == null || text.isEmpty) {
                                            return 'Story Points cant be empty';
                                          }
                                          return null;
                                        },
                                      ),
                                      Text('Task State'),
                                      DropdownButton<String>(
                                        value: data[listIndex]
                                            .items[itemIndex]
                                            .taskState,
                                        icon: const Icon(Icons.arrow_downward),
                                        elevation: 16,
                                        style: const TextStyle(
                                          color: Colors.blue,
                                        ),
                                        underline: Container(
                                          height: 2,
                                          color: Colors.blue,
                                        ),
                                        onChanged: (String? value) {
                                          setState(() {
                                            data[listIndex]
                                                .items[itemIndex]
                                                .taskState = value!;
                                          });
                                        },
                                        items: states
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _UpdateTask(data[listIndex]
                                                .items[itemIndex]);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content:
                                                        Text('Updated Task')));
                                            Navigator.of(context).pop();
                                          }
                                        },
                                        child: Text('Submit Changes'),
                                      )
                                    ],
                                  ),
                                ),
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
