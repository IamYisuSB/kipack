# Room (used by WorkManager, which the Google Mobile Ads SDK pulls in)
# instantiates each database's generated `_Impl` class by reflection. R8
# strips it in release builds otherwise, and the app crashes at startup
# with "Failed to create an instance of androidx.work.impl.WorkDatabase".
-keep class * extends androidx.room.RoomDatabase { <init>(); }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
