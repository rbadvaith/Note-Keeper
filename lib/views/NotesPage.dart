import 'package:flutter/material.dart';
import 'package:notes/constants.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes/model/note.dart';
import 'package:notes/views/NotesSearchPage.dart';
import 'package:notes/views/add_note_page.dart';
import 'package:notes/views/edit_note_page.dart';
import 'package:animations/animations.dart';

class NotesPage extends StatefulWidget {
  final int darkMode;
  final Box<dynamic> box;
  NotesPage(this.darkMode, this.box);
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  bool search = false;
  ValueNotifier<bool> delete = ValueNotifier(false);
  List<int> deleteValues = [];
  ValueNotifier<int> deleteValuesLength = ValueNotifier(0);
  String copyTitle = '', copyBody = '';
  int count = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.window.onPlatformBrightnessChanged = () {
      if (widget.darkMode == 2) widget.box.put('darkMode', 2);
    };
  }

  Future<void> deleteAll(Box<dynamic> box) async {
    deleteValues.sort();
    for (int index = deleteValues.length - 1; index >= 0; index--)
      await Note("", "", DateTime.now()).removeCard(deleteValues[index]);
  }

  @override
  Widget build(BuildContext context) {
    bool gridview = widget.box.get('gridview', defaultValue: true);
    return SafeArea(
        child: PageTransitionSwitcher(
      duration: const Duration(milliseconds: 300),
      reverse: !search,
      transitionBuilder: (
        Widget child,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return SharedAxisTransition(
          child: child,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.scaled,
        );
      },
      child: search
          ? NotesSearchPage(widget.box, () {
              setState(() {
                search = false;
              });
            })
          : WillPopScope(
              key: ValueKey("Home"),
              onWillPop: () async {
                if (delete.value) {
                  delete.value = false;
                  deleteValues.clear();
                  return false;
                } else
                  return true;
              },
              child: ValueListenableBuilder<bool>(
                  valueListenable: delete,
                  builder: (context, bool deleteMode, snapshot) {
                    return Scaffold(
                      appBar: deleteMode
                          ? AppBar(
                              key: ValueKey(0),
                              toolbarHeight: 88,
                              title: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      delete.value = false;
                                      deleteValues.clear();
                                      deleteValuesLength.value = 0;
                                    },
                                    icon: Icon(Icons.close),
                                  ),
                                  SizedBox(width: 16),
                                  ValueListenableBuilder<int>(
                                      valueListenable: deleteValuesLength,
                                      builder: (context, int deleteValuesLength,
                                          snapshot) {
                                        return Text(
                                          "${deleteValuesLength} Selected",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6,
                                        );
                                      }),
                                ],
                              ),
                              elevation: 0,
                              actions: [
                                ValueListenableBuilder<int>(
                                    valueListenable: deleteValuesLength,
                                    builder: (context, int len, snapshot) {
                                      if (len == 1)
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 4.0),
                                          child: IconButton(
                                            tooltip: 'Make a Copy',
                                            onPressed: () async {
                                              await Note(copyTitle, copyBody,
                                                      DateTime.now())
                                                  .addCard();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    duration:
                                                        Duration(seconds: 3),
                                                    elevation: 2,
                                                    content: Text(
                                                      'Note Duplicated',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText1,
                                                    )),
                                              );
                                              delete.value = false;
                                              deleteValues.clear();
                                              deleteValuesLength.value = 0;
                                            },
                                            icon: Icon(Icons.file_copy),
                                          ),
                                        );
                                      else
                                        return Container();
                                    }),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: IconButton(
                                    onPressed: () async {
                                      await deleteAll(widget.box);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            duration: Duration(seconds: 3),
                                            elevation: 2,
                                            content: Text(
                                              deleteValues.length > 1
                                                  ? '${deleteValues.length} Movie Deleted'
                                                  : 'Note Deleted',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1,
                                            )),
                                      );
                                      delete.value = false;
                                      deleteValues.clear();
                                      deleteValuesLength.value = 0;
                                    },
                                    icon: Icon(Icons.delete),
                                  ),
                                ),
                              ],
                            )
                          : AppBar(
                              key: ValueKey(1),
                              toolbarHeight: 88,
                              title: Row(
                                children: [
                                  Container(
                                    color: Colors.transparent,
                                    child: Center(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            search = true;
                                          });
                                        },
                                        child: SizedBox(
                                          width: 48,
                                          height: 48,
                                          child: Card(
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.search_outlined,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text(
                                    "Movies",
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                  ),
                                ],
                              ),
                              actions: [
                                Container(
                                  color: Colors.transparent,
                                  child: Center(
                                    child: Tooltip(
                                      message:
                                          !gridview ? "Grid View" : "List View",
                                      child: InkWell(
                                        onTap: () {
                                          widget.box.put('gridview', !gridview);
                                        },
                                        child: SizedBox(
                                          width: 48,
                                          height: 48,
                                          child: Card(
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              !gridview
                                                  ? Icons.grid_view_outlined
                                                  : Icons.view_agenda_outlined,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Container(
                                  color: Colors.transparent,
                                  child: Center(
                                    child: Tooltip(
                                      message: widget.darkMode == 2
                                          ? 'System Default'
                                          : (widget.darkMode == 1
                                              ? 'Dark Mode'
                                              : 'Light Mode'),
                                      child: InkWell(
                                        onTap: () {
                                          widget.box.put(
                                              'darkMode',
                                              widget.darkMode == 1
                                                  ? 2
                                                  : (widget.darkMode == 2
                                                      ? 0
                                                      : 1));
                                        },
                                        child: SizedBox(
                                          width: 48,
                                          height: 48,
                                          child: Card(
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              widget.darkMode == 2
                                                  ? Icons.devices_outlined
                                                  : (widget.darkMode == 1
                                                      ? Icons.dark_mode_outlined
                                                      : Icons
                                                          .light_mode_outlined),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                              ],
                              elevation: 0,
                            ),
                      floatingActionButton: OpenContainer(
                          transitionType: ContainerTransitionType.fadeThrough,
                          transitionDuration: Duration(milliseconds: 200),
                          openBuilder: (context, _) =>
                              SafeArea(child: AddNotePage(() {
                                setState(() {});
                                Navigator.of(context).pop();
                              })),
                          openColor: Theme.of(context).primaryColor,
                          closedElevation: 0,
                          closedColor: Colors.transparent,
                          closedBuilder: (context, _) => Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.cyan[300],
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: kMatte,
                                ),
                              )),
                      body: PageTransitionSwitcher(
                        transitionBuilder: (
                          Widget child,
                          Animation<double> animation,
                          Animation<double> secondaryAnimation,
                        ) {
                          return FadeThroughTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            child: child,
                            fillColor: Theme.of(context).primaryColor,
                          );
                        },
                        duration: Duration(milliseconds: 200),
                        child: gridview
                            ? AnimatedSwitcher(
                                key: ValueKey<int>(14),
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  return FadeTransition(
                                      child: child, opacity: animation);
                                },
                                child: StreamBuilder(
                                  key: ValueKey<int>(
                                      count == 1 ? --count : ++count),
                                  stream: Hive.openBox('notes').asStream(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (snapshot.hasError)
                                        return Text(snapshot.error.toString());
                                      else {
                                        final notesBox = Hive.box('notes');
                                        if (notesBox.length == 0)
                                          return Container(
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.lightbulb_rounded,
                                                    size: 64,
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text(
                                                    "Movies you add appear here",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2,
                                                  ),
                                                  SizedBox(
                                                    height: 96,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        return Container(
                                          key: PageStorageKey<String>('grid'),
                                          child: ValueListenableBuilder<int>(
                                              valueListenable:
                                                  deleteValuesLength,
                                              builder:
                                                  (context, int len, snapshot) {
                                                return GridView.builder(
                                                  padding: EdgeInsets.fromLTRB(
                                                      16, 0, 16, 16),
                                                  itemCount: notesBox.length,
                                                  physics:
                                                      BouncingScrollPhysics(),
                                                  gridDelegate:
                                                      new SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisSpacing: 4,
                                                    mainAxisSpacing: 4,
                                                    crossAxisCount:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width ~/
                                                            175,
                                                  ),
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    final note = notesBox.getAt(
                                                        notesBox.length -
                                                            index -
                                                            1) as Note;
                                                    return InkWell(
                                                      onTap: () {
                                                        if (deleteMode) {
                                                          if (deleteValues
                                                              .contains(notesBox
                                                                      .length -
                                                                  index -
                                                                  1)) {
                                                            deleteValues.remove(
                                                                notesBox.length -
                                                                    index -
                                                                    1);
                                                            deleteValuesLength
                                                                .value--;
                                                            if (deleteValues
                                                                    .length ==
                                                                0) {
                                                              delete.value =
                                                                  false;
                                                              deleteValues
                                                                  .clear();
                                                              deleteValuesLength
                                                                  .value = 0;
                                                            }
                                                            if (deleteValues
                                                                    .length ==
                                                                1) {
                                                              final copyNote =
                                                                  notesBox.getAt(
                                                                          deleteValues[
                                                                              0])
                                                                      as Note;
                                                              copyBody =
                                                                  copyNote.body;
                                                              copyTitle =
                                                                  copyNote
                                                                      .title;
                                                            } else {
                                                              copyBody = '';
                                                              copyTitle = '';
                                                            }
                                                          } else {
                                                            deleteValues.add(
                                                                notesBox.length -
                                                                    index -
                                                                    1);
                                                            deleteValuesLength
                                                                .value++;
                                                          }
                                                        }
                                                      },
                                                      onLongPress: () {
                                                        if (!deleteMode) {
                                                          delete.value = true;
                                                          deleteValues.add(
                                                              notesBox.length -
                                                                  index -
                                                                  1);
                                                          deleteValuesLength
                                                              .value++;
                                                          if (deleteValues
                                                                  .length ==
                                                              1) {
                                                            final copyNote =
                                                                notesBox.getAt(
                                                                    deleteValues[
                                                                        0]) as Note;
                                                            copyBody =
                                                                copyNote.body;
                                                            copyTitle =
                                                                copyNote.title;
                                                          } else {
                                                            copyBody = '';
                                                            copyTitle = '';
                                                          }
                                                        } else {
                                                          if (deleteValues
                                                              .contains(notesBox
                                                                      .length -
                                                                  index -
                                                                  1)) {
                                                            deleteValues.remove(
                                                                notesBox.length -
                                                                    index -
                                                                    1);
                                                            deleteValuesLength
                                                                .value--;
                                                            if (deleteValues
                                                                    .length ==
                                                                0) {
                                                              delete.value =
                                                                  false;
                                                              deleteValues
                                                                  .clear();
                                                              deleteValuesLength
                                                                  .value = 0;
                                                            }
                                                            if (deleteValues
                                                                    .length ==
                                                                1) {
                                                              final copyNote =
                                                                  notesBox.getAt(
                                                                          deleteValues[
                                                                              0])
                                                                      as Note;
                                                              copyBody =
                                                                  copyNote.body;
                                                              copyTitle =
                                                                  copyNote
                                                                      .title;
                                                            } else {
                                                              copyBody = '';
                                                              copyTitle = '';
                                                            }
                                                          } else {
                                                            deleteValues.add(
                                                                notesBox.length -
                                                                    index -
                                                                    1);
                                                            deleteValuesLength
                                                                .value++;
                                                          }
                                                        }
                                                      },
                                                      child: deleteMode
                                                          ? Card(
                                                              elevation: 0,
                                                              color: deleteValues
                                                                      .contains(
                                                                          notesBox.length -
                                                                              index -
                                                                              1)
                                                                  ? notes[(notesBox
                                                                              .length -
                                                                          index -
                                                                          1) %
                                                                      8]
                                                                  : Theme.of(
                                                                          context)
                                                                      .cardColor,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        16.0),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      note.title !=
                                                                              ''
                                                                          ? note
                                                                              .title
                                                                          : note
                                                                              .body,
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .headline5!
                                                                          .copyWith(
                                                                              color: !deleteValues.contains(notesBox.length - index - 1) ? Theme.of(context).iconTheme.color : kMatte),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      maxLines: MediaQuery.of(context).size.width ~/ 100 >
                                                                              3
                                                                          ? 3
                                                                          : MediaQuery.of(context).size.width ~/
                                                                              100,
                                                                    ),
                                                                    Text(
                                                                      months[note.created.month -
                                                                              1] +
                                                                          " " +
                                                                          note.created
                                                                              .day
                                                                              .toString() +
                                                                          ", " +
                                                                          note.created
                                                                              .year
                                                                              .toString(),
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyText2!
                                                                          .copyWith(
                                                                              color: !deleteValues.contains(notesBox.length - index - 1) ? Theme.of(context).iconTheme.color : kMatte),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          : OpenContainer(
                                                              transitionType:
                                                                  ContainerTransitionType
                                                                      .fadeThrough,
                                                              transitionDuration:
                                                                  Duration(
                                                                      milliseconds:
                                                                          200),
                                                              openBuilder:
                                                                  (context,
                                                                          _) =>
                                                                      SafeArea(
                                                                child:
                                                                    EditNotePage(
                                                                  () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  () {
                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  notesBox.length -
                                                                      index -
                                                                      1,
                                                                  note,
                                                                ),
                                                              ),
                                                              openColor: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              closedElevation:
                                                                  0,
                                                              closedColor: Theme
                                                                      .of(context)
                                                                  .primaryColor,
                                                              closedBuilder:
                                                                  (context,
                                                                          _) =>
                                                                      Container(
                                                                child: Card(
                                                                  elevation: 0,
                                                                  color: notes[
                                                                      (notesBox.length -
                                                                              index -
                                                                              1) %
                                                                          8],
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .all(
                                                                        16.0),
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          note.title != ''
                                                                              ? note.title
                                                                              : note.body,
                                                                          style: Theme.of(context)
                                                                              .textTheme
                                                                              .headline5!
                                                                              .copyWith(color: kMatte),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines: MediaQuery.of(context).size.width ~/ 100 > 3
                                                                              ? 3
                                                                              : MediaQuery.of(context).size.width ~/ 100,
                                                                        ),
                                                                        Text(
                                                                          months[note.created.month - 1] +
                                                                              " " +
                                                                              note.created.day.toString() +
                                                                              ", " +
                                                                              note.created.year.toString(),
                                                                          style: Theme.of(context)
                                                                              .textTheme
                                                                              .bodyText2!
                                                                              .copyWith(color: kMatte),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                    );
                                                  },
                                                );
                                              }),
                                        );
                                      }
                                    } else
                                      return Container();
                                  },
                                ),
                              )
                            : AnimatedSwitcher(
                                key: ValueKey<int>(15),
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  return FadeTransition(
                                      child: child, opacity: animation);
                                },
                                child: StreamBuilder(
                                  key: ValueKey<int>(
                                      count == 1 ? --count : ++count),
                                  stream: Hive.openBox('notes').asStream(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (snapshot.hasError)
                                        return Text(snapshot.error.toString());
                                      else {
                                        final notesBox = Hive.box('notes');
                                        if (notesBox.length == 0)
                                          return Container(
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.lightbulb_rounded,
                                                    size: 64,
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text(
                                                    "Movies you add appear here",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2,
                                                  ),
                                                  SizedBox(
                                                    height: 96,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        return Container(
                                          key: PageStorageKey<String>('list'),
                                          child: ValueListenableBuilder<int>(
                                              valueListenable:
                                                  deleteValuesLength,
                                              builder:
                                                  (context, int len, snapshot) {
                                                return ListView.builder(
                                                  padding: EdgeInsets.fromLTRB(
                                                      16, 0, 16, 0),
                                                  itemCount: notesBox.length,
                                                  physics:
                                                      BouncingScrollPhysics(),
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    final note = notesBox.getAt(
                                                        notesBox.length -
                                                            index -
                                                            1) as Note;
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 8.0),
                                                      child: InkWell(
                                                        onTap: () {
                                                          if (deleteMode) {
                                                            if (deleteValues
                                                                .contains(notesBox
                                                                        .length -
                                                                    index -
                                                                    1)) {
                                                              deleteValues.remove(
                                                                  notesBox.length -
                                                                      index -
                                                                      1);
                                                              deleteValuesLength
                                                                  .value--;
                                                              if (deleteValues
                                                                      .length ==
                                                                  0) {
                                                                delete.value =
                                                                    false;
                                                                deleteValues
                                                                    .clear();
                                                                deleteValuesLength
                                                                    .value = 0;
                                                              }
                                                              if (deleteValues
                                                                      .length ==
                                                                  1) {
                                                                final copyNote =
                                                                    notesBox.getAt(
                                                                            deleteValues[0])
                                                                        as Note;
                                                                copyBody =
                                                                    copyNote
                                                                        .body;
                                                                copyTitle =
                                                                    copyNote
                                                                        .title;
                                                              } else {
                                                                copyBody = '';
                                                                copyTitle = '';
                                                              }
                                                            } else {
                                                              deleteValues.add(
                                                                  notesBox.length -
                                                                      index -
                                                                      1);
                                                              deleteValuesLength
                                                                  .value++;
                                                            }
                                                          }
                                                        },
                                                        onLongPress: () {
                                                          if (!deleteMode) {
                                                            delete.value = true;
                                                            deleteValues.add(
                                                                notesBox.length -
                                                                    index -
                                                                    1);
                                                            deleteValuesLength
                                                                .value++;
                                                            if (deleteValues
                                                                    .length ==
                                                                1) {
                                                              final copyNote =
                                                                  notesBox.getAt(
                                                                          deleteValues[
                                                                              0])
                                                                      as Note;
                                                              copyBody =
                                                                  copyNote.body;
                                                              copyTitle =
                                                                  copyNote
                                                                      .title;
                                                            } else {
                                                              copyBody = '';
                                                              copyTitle = '';
                                                            }
                                                          } else {
                                                            if (deleteValues
                                                                .contains(notesBox
                                                                        .length -
                                                                    index -
                                                                    1)) {
                                                              deleteValues.remove(
                                                                  notesBox.length -
                                                                      index -
                                                                      1);
                                                              deleteValuesLength
                                                                  .value--;
                                                              if (deleteValues
                                                                      .length ==
                                                                  0) {
                                                                delete.value =
                                                                    false;
                                                                deleteValues
                                                                    .clear();
                                                                deleteValuesLength
                                                                    .value = 0;
                                                              }
                                                              if (deleteValues
                                                                      .length ==
                                                                  1) {
                                                                final copyNote =
                                                                    notesBox.getAt(
                                                                            deleteValues[0])
                                                                        as Note;
                                                                copyBody =
                                                                    copyNote
                                                                        .body;
                                                                copyTitle =
                                                                    copyNote
                                                                        .title;
                                                              } else {
                                                                copyBody = '';
                                                                copyTitle = '';
                                                              }
                                                            } else {
                                                              deleteValues.add(
                                                                  notesBox.length -
                                                                      index -
                                                                      1);
                                                              deleteValuesLength
                                                                  .value++;
                                                            }
                                                          }
                                                        },
                                                        child: deleteMode
                                                            ? Card(
                                                                elevation: 0,
                                                                color: deleteValues.contains(
                                                                        notesBox.length -
                                                                            index -
                                                                            1)
                                                                    ? notes[(notesBox.length -
                                                                            index -
                                                                            1) %
                                                                        8]
                                                                    : Theme.of(
                                                                            context)
                                                                        .cardColor,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          16.0),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        note.title !=
                                                                                ''
                                                                            ? note.title
                                                                            : note.body,
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .headline5!
                                                                            .copyWith(color: !deleteValues.contains(notesBox.length - index - 1) ? Theme.of(context).iconTheme.color : kMatte),
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        maxLines: MediaQuery.of(context).size.width ~/ 100 >
                                                                                3
                                                                            ? 3
                                                                            : MediaQuery.of(context).size.width ~/
                                                                                100,
                                                                      ),
                                                                      Text(
                                                                        months[note.created.month -
                                                                                1] +
                                                                            " " +
                                                                            note.created.day.toString() +
                                                                            ", " +
                                                                            note.created.year.toString(),
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyText2!
                                                                            .copyWith(color: !deleteValues.contains(notesBox.length - index - 1) ? Theme.of(context).iconTheme.color : kMatte),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            16,
                                                                      ),
                                                                      Text(
                                                                        note.body,
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyText1!
                                                                            .copyWith(color: !deleteValues.contains(notesBox.length - index - 1) ? Theme.of(context).iconTheme.color : kMatte),
                                                                        maxLines:
                                                                            null,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            : OpenContainer(
                                                                transitionType:
                                                                    ContainerTransitionType
                                                                        .fadeThrough,
                                                                transitionDuration:
                                                                    Duration(
                                                                        milliseconds:
                                                                            200),
                                                                openBuilder:
                                                                    (context,
                                                                            _) =>
                                                                        SafeArea(
                                                                  child:
                                                                      EditNotePage(
                                                                    () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    () {
                                                                      setState(
                                                                          () {});
                                                                    },
                                                                    (notesBox
                                                                            .length -
                                                                        index -
                                                                        1),
                                                                    note,
                                                                  ),
                                                                ),
                                                                openColor: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                closedElevation:
                                                                    0,
                                                                closedColor: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                closedBuilder:
                                                                    (context,
                                                                            _) =>
                                                                        Container(
                                                                  child: Card(
                                                                    elevation:
                                                                        0,
                                                                    color: notes[(notesBox.length -
                                                                            index -
                                                                            1) %
                                                                        8],
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                              .all(
                                                                          16.0),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                            note.title != ''
                                                                                ? note.title
                                                                                : note.body,
                                                                            style:
                                                                                Theme.of(context).textTheme.headline5!.copyWith(color: kMatte),
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            maxLines: MediaQuery.of(context).size.width ~/ 100 > 3
                                                                                ? 3
                                                                                : MediaQuery.of(context).size.width ~/ 100,
                                                                          ),
                                                                          Text(
                                                                            months[note.created.month - 1] +
                                                                                " " +
                                                                                note.created.day.toString() +
                                                                                ", " +
                                                                                note.created.year.toString(),
                                                                            style:
                                                                                Theme.of(context).textTheme.bodyText2!.copyWith(color: kMatte),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                16,
                                                                          ),
                                                                          Text(
                                                                            note.body,
                                                                            style:
                                                                                Theme.of(context).textTheme.bodyText1!.copyWith(color: kMatte),
                                                                            maxLines:
                                                                                null,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              }),
                                        );
                                      }
                                    } else
                                      return Container();
                                  },
                                ),
                              ),
                      ),
                    );
                  }),
            ),
    ));
  }
}
