{\rtf1\ansi\ansicpg1252\cocoartf1038\cocoasubrtf360
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
\paperw11900\paperh16840\margl1440\margr1440\vieww9000\viewh8400\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\ql\qnatural\pardirnatural

\f0\fs24 \cf0 IQDatabaseManager\uc0\u8232 =============\u8232 IQDatabaseManager contains CoreData helper classes with convenience methods to communicate with CoreData for performing common tasks(inserting+updating+deleting+sorting+searching) on database records.\u8232 IQDatabaseManager Features:-\u8232 ---\u8232 1) Convenience methods to Insert, Update, Delete records.\u8232 2) Convenience methods to do Searching and Sorting.\
\
IQOfflineManager\uc0\u8232 =============\u8232 I also created a subclass called IQOfflineManager which provide methods to communicate with web-services.\u8232 IQOfflineManager Features:-\u8232 ---\u8232 1) It stores the NSData for later use when offline.(Downloading+Offline)\u8232 2) It stores the NSURLRequest object and send request to upload data when an internet connection found.(Uploading+Offline)\
\
MyDatabaseManager\uc0\u8232 =============\u8232 I created another subclass called MyDatabaseManager for demo purpose.\
\
Usage:-\uc0\u8232 ---\u8232 Step1:- Subclass `IQDatabaseManager`.\u8232 Step2:- Create your `Data Model`.\u8232 Step3:- Create your `Entities` in your `Data Model`.\u8232 Step3:- Override `+(NSString*)modelName;` abstract method of `IQDatabaseManager` in your subclass and return your DataModel name.\u8232 Step4:- Don't modify `IQDatabaseManger` class, just write your own wrapper class with your DataModel entities.\
\
LICENSE\uc0\u8232 =============\u8232 Distributed under the MIT License.\
\
Contributions\uc0\u8232 =============\u8232 Any contribution is more than welcome! You can contribute through pull requests and issues on GitHub.\
\
Author\uc0\u8232 =============\u8232 If you wish to contact me, email at: hack.iftekhar@gmail.com\
}