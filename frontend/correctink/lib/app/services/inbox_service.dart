import 'dart:async';
import 'dart:ffi';

import 'package:correctink/app/data/repositories/collections/users_collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:objectid/objectid.dart';
import 'package:realm/realm.dart';

import '../data/models/schemas.dart';

enum InboxEventsType {
  newMessageReceived,
  messageReadUpdated,
  messageDeleted,
}

class InboxService with ChangeNotifier {
  late Users _user;
  Inbox get inbox => _user.inbox!;
  late StreamSubscription _newMessagesStream;
  late StreamSubscription _receivedMessageStream;

  List<UserMessage> get unreadMessages => inbox.receivedMessages.where((message) => !message.read).toList();
  int unreadMessagesCount = 0;

  List<UserMessage> get readMessages => inbox.receivedMessages.where((message) => message.read).toList();
  int get readMessagesCount => readMessages.length;

  InboxService(this._user) {
    _newMessagesStream = inbox.newMessages.changes.listen((event) {
      if(event.inserted.isNotEmpty) {
        _newMessage();
      }
    });
    _receivedMessageStream = inbox.receivedMessages.changes.listen((event) {
      unreadMessagesCount = unreadMessages.length;
      notifyListeners();
    });

    checkReceivedMessagesValidity();
  }

  void init(Users user) {
    _user = user;

    _newMessagesStream.cancel();
    _receivedMessageStream.cancel();

    _newMessagesStream = inbox.newMessages.changes.listen((event) {
      if(event.inserted.isNotEmpty) {
        _newMessage();
      }
    });
    _receivedMessageStream = inbox.receivedMessages.changes.listen((event) {
      unreadMessagesCount = unreadMessages.length;
      notifyListeners();
    });

    checkReceivedMessagesValidity();
  }

  void checkReceivedMessagesValidity() {
    List<UserMessage> messagesToDelete = [];
    for(final message in inbox.receivedMessages) {
      if(message.message == null) {
        messagesToDelete.add(message);
      }
    }

    if(messagesToDelete.isNotEmpty) {
      inbox.realm.writeAsync(() => inbox.realm.deleteMany(messagesToDelete));
    }
  }

  void _newMessage() {
    List<UserMessage> newReceivedMessage = [];
    for(Message message in inbox.newMessages) {
      UserMessage userMessage = UserMessage(ObjectId(), message: message);
      newReceivedMessage.add(userMessage);
    }

    inbox.realm.writeAsync(() => {
      inbox.receivedMessages.addAll(newReceivedMessage),
      inbox.newMessages.clear(),
    });
  }

  void markAsRead(UserMessage message) {
    inbox.realm.writeAsync(() => {
      message.read = !message.read,
    });
  }

  void markAllAsRead() {
    inbox.realm.writeAsync(() => {
      for(UserMessage message in unreadMessages) {
        message.read = true,
      }
    });
  }

  void delete(UserMessage message) {
    inbox.realm.writeAsync(() => inbox.realm.delete(message));
  }

  void deleteAll() {
    inbox.realm.writeAsync(() => inbox.realm.deleteMany(inbox.receivedMessages));
  }

  void deleteMessage(Message message) {
    if(_user.role >= UserService.moderator) {
      inbox.realm.writeAsync(() => inbox.realm.delete(message));
    }
  }

  void broadcast(String title, String message, int type, int dest) {
    if(_user.role < UserService.moderator) return;

    Message messageToSend = Message(ObjectId(), title, message, type, DateTime.now(), DateTime.now().add(const Duration(days: 2)));

    String query = r'role >= $0 && _id != $1';
    final users = inbox.realm.query<Users>(query, [dest, _user.userId]);

    inbox.realm.writeAsync(() => {
      for(Users user in users) {
        user.inbox?.newMessages.add(messageToSend),
      },
      inbox.sendMessages.add(messageToSend),
    });
  }

  void sendAutomaticMessageToUser(String title, String message, int type, Users user) {
    Message messageToSend = Message(ObjectId(), title, message, type, DateTime.now(), DateTime.now().add(const Duration(days: 100)));

    String query = r'_id == $0';
    final users = inbox.realm.query<Users>(query, [user.userId]);

    inbox.realm.writeAsync(() => {
      for(Users user in users) {
        user.inbox?.newMessages.add(messageToSend),
      },
    });
  }

  void update(Message originalMessage, String title, String message, int type) {
    if(_user.role < UserService.moderator) return;
    inbox.realm.writeAsync(() => {
      originalMessage.title = title,
      originalMessage.message = message,
      originalMessage.icon = type,
    });
  }

  void sendReport(ReportMessage report) {
    // admin for testing => will be me
    List<Users> moderators = inbox.realm.query<Users>("role >= ${UserService.admin}").toList();
    moderators.sort((m1, m2) => m1.inbox!.reports.length.compareTo(m2.inbox!.reports.length));
    int minReportCountPerMod = moderators.first.inbox!.reports.length;

    // pick any of the moderator with the least report
    moderators = moderators.where((mod) => mod.inbox!.reports.length == minReportCountPerMod).toList();
    moderators.shuffle();

    inbox.realm.writeAsync(() {
      moderators.first.inbox?.reports.add(report);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _newMessagesStream.cancel();
    _receivedMessageStream.cancel();
  }
}