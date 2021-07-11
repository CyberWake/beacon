import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:beacon/models/user/user_info.dart';
import '../locator.dart';

class UserConfig {
  User _currentUser = User(id: 'null', authToken: 'null');
  User get currentUser => _currentUser;

  Future<bool> userLoggedIn() async {
    final boxUser = Hive.box<User>('currentUser');
    _currentUser = boxUser.get('user');
    if (_currentUser == null) {
      _currentUser = User(id: 'null', authToken: 'null');
      return false;
    }
    bool userUpdated = true;
    graphqlConfig.getToken().then((value) async {
      print('${userConfig._currentUser.authToken}');
      databaseFunctions.init();
      final bool fetchUpdates = await databaseFunctions.fetchCurrentUserInfo();
      if (fetchUpdates) {
        saveUserInHive();
        userUpdated = true;
      } else {
        navigationService.showSnackBar("Couldn't update User details");
        userUpdated = false;
      }
    });
    return userUpdated;
  }

  Future<bool> updateUser(User updatedUserDetails) async {
    try {
      _currentUser = updatedUserDetails;
      saveUserInHive();
      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  saveUserInHive() {
    final box = Hive.box<User>('currentUser');
    if (box.get('user') == null) {
      box.put('user', _currentUser);
    } else {
      box.put('user', _currentUser);
    }
  }
}