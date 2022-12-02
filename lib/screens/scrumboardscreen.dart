import 'package:boardview/board_item.dart';
import 'package:boardview/board_list.dart';
import 'package:boardview/boardview.dart';
import 'package:boardview/boardview_controller.dart';
import 'package:flutter/material.dart';
import 'package:my_app/BoardListObject.dart';
import 'package:my_app/FirebaseNotify.dart';
import 'package:my_app/ScrumTaskManager.dart';

class ScrumBoard extends StatefulWidget {
  const ScrumBoard({super.key});
  @override
  State<ScrumBoard> createState() => _ScrumBoardState();
}

class _ScrumBoardState extends State<ScrumBoard> {
  late ScrumTaskManager manager;
  late FirebaseNotify notify;
  //This data is the one being showed on the screen
  List<BoardPostColumn> data = [];
    //_formkey is used to validate that all forms fields are valid
  final _formKey = GlobalKey<FormState>();

  //Used for DropDownMenu
  final List<String> states = ['Todo', 'In Progress', 'Done'];
  String stringstate = 'Todo';

  late BoardViewController boardViewController;
  final List<TextEditingController> textscontrollers =
      List.generate(3, (i) => TextEditingController());

  /**
   * Gets data from ScrumTaskManger and assigns the data to List<BoardPostColumn> data
   */
  Future<List<BoardPostColumn>> GetData() async {
    if (data.isEmpty) {
      data = await manager.GetData();
    }
    return data;
  }

/**
 * Calls api to remove task using the index parameter
 * SetState and removes BoardPost object from data object where the id is equal to the index provided
 */
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
/**Takes in a BoardPost object and assigns the task property to be equal to the TextControllers
 * Calls api to update task 
 */
  void _UpdateTask(BoardPost task) async {
    task.taskName = textscontrollers[0].text;
    task.taskDescription = textscontrollers[1].text;
    task.storyPoints = int.parse(textscontrollers[2].text);
    await manager.UpdateTask(task);
    //Needs to call GetData method, otherwise the UI would not update
    //Gets a List<BoardPostColumn>
    var result = await manager.GetData();
    setState(() {
      //sets the data to be equal to result from GetData
      data = result;
      stringstate = "Todo";
      textscontrollers[0].clear();
      textscontrollers[1].clear();
      textscontrollers[2].clear();
    });
  }

  /**Creates a new BoardPost object and sets the data from TextsControllers
   * Calls api to create task
   */
  void _AddTask() async {
    BoardPost task = BoardPost();
    task.taskName = textscontrollers[0].text;
    task.taskDescription = textscontrollers[1].text;
    task.storyPoints = int.parse(textscontrollers[2].text);
    task.taskState = stringstate;
    //Gets a BoardPost object
    var result = await manager.CreateTask(task);
    //depending on which the newly task is we add it the to data object
    if (result.taskState?.toLowerCase() == "todo") {
      setState(() {
        stringstate = "Todo";
        textscontrollers[0].clear();
        textscontrollers[1].clear();
        textscontrollers[2].clear();
        data[0].items.add(result);
      });
    }
    if (result.taskState?.toLowerCase() == "in progress") {
      setState(() {
        stringstate = "Todo";
        textscontrollers[0].clear();
        textscontrollers[1].clear();
        textscontrollers[2].clear();
        data[1].items.add(result);
      });
    }
    if (result.taskState?.toLowerCase() == "done") {
      setState(() {
        stringstate = "Todo";
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
    //Calls different Firebase methods to make the notication work
    notify = FirebaseNotify();
    notify.requestPermission();
    notify.loadFCM();
    notify.listenFCM();
    notify.getToken();
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
      //uses a FutureBuilder because ones data object is not null, it will start displaying the data, or if data object has changed
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
      //Created a simple button that opens a dialog where you can specify a new task
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                //Uses a StatefulBuilder because otherwise the DropdownMenu will not update
                //The StatefulBuilder, creates a widget that both has state and delegates its build to a callback.
                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setStateSb) =>
                      AlertDialog(
                    title: const Text('Add Task'),
                    content: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text('Task Name'),
                          TextFormField(
                            controller: textscontrollers[0],
                            decoration:
                                const InputDecoration(hintText: "Name of task"),
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Task Name cant be empty';
                              }
                              return null;
                            },
                          ),
                          const Text('Task Description'),
                          TextFormField(
                            controller: textscontrollers[1],
                            decoration: const InputDecoration(
                                hintText: "Task Description"),
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Task Description cant be empty';
                              }
                              return null;
                            },
                          ),
                          const Text('Story Points'),
                          TextFormField(
                            controller: textscontrollers[2],
                            decoration: const InputDecoration(
                              hintText: "Story points",
                            ),
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Story Points cant be empty';
                              }
                              return null;
                            },
                          ),
                          const Text('Task State'),
                          DropdownButton(
                            value: stringstate,
                            icon: const Icon(Icons.arrow_downward),
                            elevation: 16,
                            style: const TextStyle(
                              color: Colors.blue,
                            ),
                            underline: Container(
                              height: 2,
                              color: Colors.blue,
                            ),
                            //States is a list that contains "To do" "In Progress" or "Done"
                            items: states.map((String items) {
                              return DropdownMenuItem(
                                value: items,
                                child: Text(items),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setStateSb(() {
                                stringstate = value!;
                              });
                            },
                          ),
                          ElevatedButton(
                            onPressed: () {
                              //if form is valid we call the _AddTask method
                              if (_formKey.currentState!.validate()) {
                                setStateSb(() {
                                  _AddTask();
                                });
                              //Shows a little pop op on the bottom of screen that task has being added
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Added Task')));

                                Navigator.of(context).pop();
                                //Sends a push notication with the new task name
                                notify.sendPushMessage(
                                    'User added new task: ${textscontrollers[0].text}',
                                    'Added Task');
                              }
                            },
                            child: const Text('Submit'),
                          )
                        ],
                      ),
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

  /**Creates a [BoardList] with drag n drop functionality
   * Takes in a BoardPostColumn and BuildContext as parameter
   * Returns a BoardView
   */
  
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

  /**Creates each individuel [BoardItem] of [BoardPost] that will be used in the [BoardList]
   * Creates a onTapItem that opens a Dialog, where you can delete or update the selected task
  */
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
                        //Sends a push notication when a task is deleted
                        notify.sendPushMessage(
                            'User deleted task ${data[listIndex].items[itemIndex].taskName}',
                            'Deleted Task');
                      },
                    ),
                    TextButton(
                        child: Text('Change'),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                //Uses a StatefulBuilder because otherwise the DropdownMenu will not update
                                //The StatefulBuilder, creates a widget that both has state and delegates its build to a callback.
                                return StatefulBuilder(
                                  builder: (BuildContext context,
                                          StateSetter setStateSb) =>
                                      AlertDialog(
                                    title: Text('Update Task'),
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
                                                    .taskName),
                                            validator: (text) {
                                              if (text == null ||
                                                  text.isEmpty) {
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
                                                    .taskDescription),
                                            validator: (text) {
                                              if (text == null ||
                                                  text.isEmpty) {
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
                                              if (text == null ||
                                                  text.isEmpty) {
                                                return 'Story Points cant be empty';
                                              }
                                              return null;
                                            },
                                          ),
                                          Text('Task State'),
                                          DropdownButton(
                                            value: data[listIndex]
                                                .items[itemIndex]
                                                .taskState,
                                            icon: const Icon(
                                                Icons.arrow_downward),
                                            elevation: 16,
                                            style: const TextStyle(
                                              color: Colors.blue,
                                            ),
                                            underline: Container(
                                              height: 2,
                                              color: Colors.blue,
                                            ),
                                            items: states.map((String items) {
                                              return DropdownMenuItem(
                                                value: items,
                                                child: Text(items),
                                              );
                                            }).toList(),
                                            onChanged: (String? value) {
                                              setStateSb(() {
                                                data[listIndex]
                                                    .items[itemIndex]
                                                    .taskState = value!;
                                              });
                                            },
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                               //if form is valid we call the _AddTask method
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                setStateSb(() {
                                                  _UpdateTask(data[listIndex]
                                                      .items[itemIndex]);
                                                });

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(
                                                        content: Text(
                                                            'Updated Task')));
                                                Navigator.of(context).pop();
                                                  //Sends a push notication with the updated task name
                                                notify.sendPushMessage(
                                                    'User updated task ${data[listIndex].items[itemIndex].taskName}',
                                                    'Updated Task');
                                              }
                                            },
                                            child: Text('Submit Changes'),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              });
                        }),
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
