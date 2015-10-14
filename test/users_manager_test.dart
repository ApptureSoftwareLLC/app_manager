import 'package:test/test.dart';
import 'dart:async';
import 'package:objectory/objectory_console.dart';
import '../bin/managers/users_manager.dart' as user_mgr;
import '../bin/config/mongo.dart' as mongo;

void main() {
  test("init database", () async {
    var value = await mongo.initialize();
  });

  allTests();

  test("close database", () async {
    var value = await objectory.close();
  });
}

void allTests()  {
  test ("Clean database", ()async {
    await objectory.dropCollections();
  });
  group ("User", () {
    var email = 'test@test.com';
    var password = 'password';
    var name = 'user name';

    test("Create user empty fields", () async {
      //expect(new Future.error(new StateError("bad state")), throwsStateError);
      var user = user_mgr.createUser(name, null, password);
      expect(user, throwsStateError);
      user =  user_mgr.createUser(name, email, null);
      expect(user, throwsStateError);
    });

    test("Create user", () async {
      var user =  user_mgr.createUser(name, email, password);
      expect(user, isNotNull);
    });

    test("Create same user", () async {
      //try to create same user
      var sameUser =  user_mgr.createUser(name, email, password);
      expect(sameUser, throwsStateError);
    });

    test("retrieve user", () async {
      var user =  await user_mgr.findUserByEmail(email);
      expect(user.name, equals(name));
      expect(user.email, equals(email));
      expect(user.password, equals(password));
      expect(user.isSystemAdmin, equals(false));
    });

    test("authenticate user Not found", () async {
      var user = await user_mgr.authenticateUser("anotheremail",'badpassword');
      expect(user, isNull);
    });

    test("authenticate user KO", () async {
      var user = await user_mgr.authenticateUser(email,'badpassword');
      expect(user, isNull);
    });

    test("authenticate user OK", () async {
      var user = await user_mgr.authenticateUser(email,password);
      expect(user.name, equals(name));
      expect(user.email, equals(email));
    });

    test("modify user", () async {
      var user = await user_mgr.findUserByEmail(email);
      var newname = "newName";
      user.name = newname;
      user.isSystemAdmin = true;
      user.save();

      user = await user_mgr.findUserByEmail(email);
      expect(user.name, equals(newname));
      expect(user.isSystemAdmin, equals(true));
    });

    test("alls users", () async {
      var allUsers = await user_mgr.allUsers();
      expect(allUsers.length,equals(1));
    });

    test("delete user", () async {
      var user = await user_mgr.findUserByEmail(email);
      expect(user.email, equals(email));
      await user_mgr.deleteUserByEmail(email);
      //retrieve user ?
      user = await user_mgr.findUserByEmail(email);
      expect(user,isNull);
    });

    test("delete user again", () async {
      var result = false;
      try {
        var result = await user_mgr.deleteUserByEmail(email);
      }on StateError catch (e){
        result = true;
       expect((e is  user_mgr.UserError), isTrue);
    }
      expect(result,isTrue);
    });
  });
}