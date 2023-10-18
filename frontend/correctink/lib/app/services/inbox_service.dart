import 'dart:async';

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
  final Inbox inbox;
  final int _userRole;
  late StreamSubscription _newMessagesStream;
  late StreamSubscription _receivedMessageStream;

  List<UserMessage> get unreadMessages => inbox.receivedMessages.where((message) => !message.read).toList();
  int unreadMessagesCount = 0;

  List<UserMessage> get readMessages => inbox.receivedMessages.where((message) => message.read).toList();
  int get readMessagesCount => readMessages.length;

  InboxService(this.inbox, this._userRole) {
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
    if(_userRole >= UserService.moderator) {
      inbox.realm.writeAsync(() => inbox.realm.delete(message));
    }
  }

  void send(String title, String message, int type, int dest) {
    if(_userRole < UserService.moderator) return;

    Message messageToSend = Message(ObjectId(), title, message, type, DateTime.now(), DateTime.now().add(const Duration(days: 2)));

    String query = r"TRUEPREDICATE";
    if(dest != 0) {
      query = 'role >= $dest';
    }
    final users = inbox.realm.query<Users>(query);

    inbox.realm.writeAsync(() => {
      for(Users user in users) {
        user.inbox?.newMessages.add(messageToSend),
      },
      inbox.sendMessages.add(messageToSend),
    });
  }

  void update(Message originalMessage, String title, String message, int type) {
    if(_userRole < UserService.moderator) return;
    inbox.realm.writeAsync(() => {
      originalMessage.title = title,
      originalMessage.message = message,
      originalMessage.type = type,
    });
  }

  @override
  void dispose() {
    super.dispose();
    _newMessagesStream.cancel();
    _receivedMessageStream.cancel();
  }
}