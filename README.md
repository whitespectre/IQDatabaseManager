IQDatabaseManager
=============
IQDatabaseManager contains CoreData helper classes with convenience methods to communicate with CoreData for performing common tasks(inserting+updating+deleting+sorting+searching) on database records.
## IQDatabaseManager Features:-

1) Convenience methods to Insert, Update, Delete records.

2) Convenience methods to do Searching and Sorting.


MyDatabaseManager
---
I created another subclass called MyDatabaseManager for demo purpose.


## Usage:-

Step1:- Just subclass `IQDatabaseManager`.

Step2:- Create your `Data Model`.

Step3:- Create your `Entities` in your `Data Model`.

Step4:- Override `+(NSString*)modelName;` abstract method of `IQDatabaseManager` in your subclass and return your DataModel name.

Step5:- Don't modify `IQDatabaseManger` class, just write your own wrapper in your subclass with your DataModel entities.

LICENSE
---
Distributed under the MIT License.

Contributions
---
Any contribution is more than welcome! You can contribute through pull requests and issues on GitHub.

Author
---
If you wish to contact me, email at: hack.iftekhar@gmail.com
