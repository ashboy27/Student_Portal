import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('academic_portal.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Create tables in the database
  static Future<void> _onCreate(Database db, int version) async {
    // User Table
    await db.execute('''
      CREATE TABLE User(
        User_Id INTEGER PRIMARY KEY AUTOINCREMENT,
        User_Name TEXT,
        CNIC TEXT,
        Email_Id TEXT,
        Password TEXT,
        Phone_Number TEXT,
        Address TEXT,
        User_Type TEXT CHECK(User_Type IN ('Student', 'Teacher'))
      )
    ''');

    // Student Table
    await db.execute('''
      CREATE TABLE Student(
        Student_Id TEXT PRIMARY KEY,
        User_Id INTEGER,
        Department TEXT,
        Batch INTEGER,
        Section TEXT,
        FOREIGN KEY(User_Id) REFERENCES User(User_Id)
      )
    ''');

    // Teacher Table
    await db.execute('''
      CREATE TABLE Teacher(
        Teacher_Id TEXT PRIMARY KEY,
        User_Id INT,
        Hire_Date TEXT,
        Salary INTEGER,
        FOREIGN KEY(User_Id) REFERENCES User(User_Id)
      )
    ''');

    // Course Table
    await db.execute('''
      CREATE TABLE Course(
        Course_Code TEXT PRIMARY KEY,
        Course_Name TEXT,
        Credit_Hrs INTEGER,
        Semester INTEGER,
        Prereq_Id TEXT,
        Course_Type TEXT,
        FOREIGN KEY(Prereq_Id) REFERENCES Course(Course_Code)
      )
    ''');

    // Teacher_Section_Course Table
    await db.execute('''
      CREATE TABLE Teacher_Section_Course(
        Section_Id TEXT,
        Teacher_Id TEXT,
        Course_Code TEXT,
        PRIMARY KEY(Section_Id,Course_Code,Teacher_Id),
        FOREIGN KEY(Teacher_Id) REFERENCES Teacher(Teacher_Id),
        FOREIGN KEY(Course_Code) REFERENCES Course(Course_Code)
      )
    ''');

    // Enrollment Table
    await db.execute('''
      CREATE TABLE Enrollment(
        Course_Code TEXT,
        Student_Id TEXT,
        Section_Id TEXT,
        PRIMARY KEY(Course_Code, Student_Id),
        FOREIGN KEY(Course_Code) REFERENCES Course(Course_Code),
        FOREIGN KEY(Student_Id) REFERENCES Student(Student_Id),
        FOREIGN KEY(Section_Id) REFERENCES Teacher_Section_Course(Section_Id)
      )
    ''');

    // Announcement Table
    await db.execute('''
  CREATE TABLE Announcement(
    Announcement_Id INTEGER PRIMARY KEY AUTOINCREMENT,
    User_Id INTEGER,
    Section_Id TEXT,
    Course_Code TEXT,
    Upload_time TEXT,
    Upload_date TEXT,
    Content TEXT,
    
    FOREIGN KEY(User_Id) REFERENCES User(User_Id),
    FOREIGN KEY(Section_Id) REFERENCES Teacher_Section_Course(Section_Id),
    FOREIGN KEY(Course_Code) REFERENCES Teacher_Section_Course(Course_Code)
  )
''');

    // Assignments Table
    await db.execute('''
      CREATE TABLE Assignments(
        Assignment_Id INTEGER PRIMARY KEY AUTOINCREMENT,
        Course_Code TEXT,
        Teacher_Id TEXT,
        Section_Id TEXT,
        Due_Date TEXT,
        Due_Time TEXT,
        Upload_Date TEXT,
        Upload_Time TEXT,
        Document TEXT,
        Upload_Text TEXT,
        Total_Marks INTEGER,
        FOREIGN KEY(Section_Id) REFERENCES Teacher_Section_Course(Section_Id),
        FOREIGN KEY(Teacher_Id) REFERENCES Teacher_Section_Course(Teacher_Id),
        FOREIGN KEY(Course_Code) REFERENCES Teacher_Section_Course(Course_Code)
      )
    ''');

    // StudentAssignment Table
    await db.execute('''
      CREATE TABLE StudentAssignment(
        Course_Code TEXT,
        Assignment_Id TEXT,
        Student_Id TEXT,
        Submit_Date TEXT,
        Submit_Time TEXT,
        Document TEXT,
        PRIMARY KEY(Course_Code, Assignment_Id, Student_Id),
        FOREIGN KEY(Course_Code) REFERENCES Course(Course_Code),
        FOREIGN KEY(Assignment_Id) REFERENCES Assignments(Assignment_Id),
        FOREIGN KEY(Student_Id) REFERENCES Student(Student_Id)
      )
    ''');

    // ToDo_List Table
    await db.execute('''
      CREATE TABLE ToDo_List(
        Assignment_Id TEXT,
        Status INTEGER,
        FOREIGN KEY(Assignment_Id) REFERENCES Assignments(Assignment_Id)
      )
    ''');

    // Exam Table
    await db.execute('''
      CREATE TABLE Exam(
        Exam_Id TEXT PRIMARY KEY,
        Section_Id TEXT,
        Exam_Title TEXT,
        Course_Code TEXT,
        Student_Id TEXT,
        Total_Marks INTEGER,
        Obtained_Marks INTEGER,
        FOREIGN KEY(Section_Id) REFERENCES Teacher_Section_Course(Section_Id),
        FOREIGN KEY(Course_Code) REFERENCES Teacher_Section_Course(Course_Code),
        FOREIGN KEY(Student_Id) REFERENCES Student(Student_Id)
      )
    ''');

    // Assignment_Marks Table
    await db.execute('''
      CREATE TABLE Assignment_Marks(
        Assignment_Id TEXT,
        Student_Id TEXT,
        Marks_Obtained REAL,
        Grading_Date TEXT,
        Feedback TEXT,
        FOREIGN KEY(Assignment_Id) REFERENCES Assignments(Assignment_Id),
        FOREIGN KEY(Student_Id) REFERENCES Student(Student_Id)
      )
    ''');

    // Attendance Table
    await db.execute('''
      CREATE TABLE Attendance(
        Course_Code TEXT,
        Student_Id TEXT,
        Attend_Date TEXT,
        Status INTEGER,
        PRIMARY KEY(Course_Code, Student_Id, Attend_Date),
        FOREIGN KEY(Course_Code) REFERENCES Course(Course_Code),
        FOREIGN KEY(Student_Id) REFERENCES Student(Student_Id)
      )
    ''');
  }

  //insert queries
  Future<void> insertUser({
    required String fullName,
    required String cnic,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String userType,
    String? studentId,
    String? department,
    int? batch,
    String? section,
    String? teacherId,
    String? hireDate,
    int? salary,
  }) async {
    final db = await instance.database;

    // Insert into User table
    int userId = await db.insert('User', {
      'User_Name': fullName,
      'CNIC': cnic,
      'Email_Id': email,
      'Password': password,
      'Phone_Number': phone,
      'Address': address,
      'User_Type': userType,
    });

    if (userType == 'Student') {
      await db.insert('Student', {
        'Student_Id': studentId,
        'User_Id': userId,
        'Department': department,
        'Batch': batch,
        'Section': section,
      });
    } else if (userType == 'Teacher') {
      await db.insert('Teacher', {
        'Teacher_Id': teacherId,
        'User_Id': userId,
        'Hire_Date': hireDate,
        'Salary': salary,
      });
    }
  }

  Future<void> addCourse(
    String courseCode,
    String courseName,
    int creditHrs,
    int semester,
    String? prereqId,
    String courseType,
  ) async {
    final db = await instance.database;

    await db.insert(
      'Course',
      {
        'Course_Code': courseCode,
        'Course_Name': courseName,
        'Credit_Hrs': creditHrs,
        'Semester': semester,
        'Prereq_Id': prereqId,
        'Course_Type': courseType,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> assignTeacherToCourse(
      String sectionId, String teacherId, String courseCode) async {
    final db = await database;
    try {
      await db.insert('Teacher_Section_Course', {
        'Section_Id': sectionId,
        'Teacher_Id': teacherId,
        'Course_Code': courseCode,
      });
      return true; // Success
    } catch (e) {
      return false; // Error occurred
    }
  }

  Future<void> addAnnouncement(int userId, String sectionId, String courseCode,
      String content, String uploadDate, String uploadTime) async {
    final db = await database;

    await db.insert(
      'Announcement',
      {
        'User_Id': userId,
        'Section_Id': sectionId,
        'Course_Code': courseCode,
        'Content': content,
        'Upload_date': uploadDate,
        'Upload_time': uploadTime,
      },
    );
  }

  Future<void> registerCourse(String studentId, String courseCode, String section) async {
    final db = await instance.database;

    await db.insert('Enrollment', {
        'Course_Code': courseCode,
        'Student_Id': studentId,
        'Section_Id': section,
    });

  }

  Future<void> addAssignment({
    required String courseCode,
    required String sectionId,
    required String teacherId,
    required String dueDate,
    required String dueTime,
    required String uploadDate,
    required String uploadTime,
    required String documentPath, // File path instead of BLOB
    required String title,
    required int totalMarks,
  }) async {
    final db = await instance.database;
    await db.insert(
      'Assignments',
      {
        'Course_Code': courseCode,
        'Section_Id': sectionId,
        'Teacher_Id': teacherId,
        'Due_Date': dueDate,
        'Due_Time': dueTime,
        'Upload_Date': uploadDate,
        'Upload_Time': uploadTime,
        'Document': documentPath, // Store file path
        'Upload_Text': title,
        'Total_Marks': totalMarks,
      },
    );
  }

// Save attendance for a specific course, section, and student on a given date
  Future<void> saveAttendance(String courseCode, String studentId, String attendDate, int status) async {
    final db = await instance.database;
    await db.rawInsert('''
    INSERT OR REPLACE INTO Attendance (Course_Code, Student_Id, Attend_Date, Status)
    VALUES (?, ?, ?, ?)
  ''', [courseCode, studentId, attendDate, status]);
  }



  //Fetch queries

  Future<Map<String, dynamic>?> getUserByIdAndPassword(
      String id, String password, String userType) async {
    final db = await instance.database;
    final tableName = userType == 'Student' ? 'Student' : 'Teacher';
    final idColumn = userType == 'Student' ? 'Student_Id' : 'Teacher_Id';

    final result = await db.rawQuery('''
    SELECT *
    FROM User u
    JOIN $tableName t ON u.User_Id = t.User_Id
    WHERE t.$idColumn = ? AND u.Password = ?
  ''', [id, password]);

    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserDetail(
      int userId, String userType) async {
    final db = await database;

    String query;
    List<dynamic> queryArgs;

    // Adjust query based on user type
    if (userType == 'Student') {
      query = '''
      SELECT *
      FROM User AS u
      LEFT JOIN Student AS s ON s.user_Id = u.User_Id
      WHERE u.User_Id = ?''';
      queryArgs = [userId];
    } else if (userType == 'Teacher') {
      query = '''
      SELECT *
      FROM User AS u
      LEFT JOIN Teacher AS t ON t.user_Id = u.User_Id
      WHERE u.User_Id = ?''';
      queryArgs = [userId];
    } else {
      return null; // Return null if the user type is not recognized
    }

    // Execute the query
    final List<Map<String, dynamic>> result =
        await db.rawQuery(query, queryArgs);

    if (result.isNotEmpty) {
      return result.first; // Return the first matching record
    }

    return null; // Return null if no match
  }

  Future<List<Map<String, dynamic>>> getClassroomsByTeacher(
      String teacherId) async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT tsc.Section_Id, c.Course_Name, c.Course_Code,u.User_Name AS User_Name
    FROM Teacher_Section_Course tsc
    JOIN Course c ON tsc.Course_Code = c.Course_Code
    JOIN Teacher t ON tsc.Teacher_Id = t.Teacher_Id
    JOIN User u ON t.User_Id = u.User_Id
    WHERE tsc.Teacher_Id = ?
  ''', [teacherId]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getTeacherSectionCourse() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''SELECT *
       FROM Teacher_Section_Course''');

    return result;
  }

  Future<List<Map<String, dynamic>>> getClassroomsByStudent(
      String studentId) async {
    final db = await database;

    return await db.rawQuery('''
    SELECT c.Course_Code, c.Course_Name, c.Credit_Hrs, c.Course_Type, 
           e.Section_Id, u.User_Name
    FROM Enrollment e
    INNER JOIN Course c ON e.Course_Code = c.Course_Code
    LEFT JOIN Teacher_Section_Course tsc ON tsc.Course_Code = c.Course_Code AND tsc.Section_Id = e.Section_Id
    LEFT JOIN Teacher t ON t.Teacher_Id = tsc.Teacher_Id
    LEFT JOIN User u ON u.User_Id = t.User_Id
    WHERE e.Student_Id = ?
  ''', [studentId]);
  }


  Future<String> getUserId(int id, String userType) async {
    final db = await database;

    String query = '';
    List<dynamic> whereArgs = [];

    if (userType.toLowerCase() == 'teacher') {
      // Query to get Teacher_Id from Teacher table based on User_Id
      query = 'SELECT Teacher_Id FROM Teacher WHERE User_Id = ?';
      whereArgs = [id];
    } else if (userType.toLowerCase() == 'student') {
      // Query to get Student_Id from Student table based on User_Id
      query = 'SELECT Student_Id FROM Student WHERE User_Id = ?';
      whereArgs = [id];
    }

    final result = await db.rawQuery(query, whereArgs);

    if (result.isNotEmpty) {
      // Return the Teacher_Id or Student_Id as a string
      return result.first[userType == 'Teacher' ? 'Teacher_Id' : 'Student_Id']
          .toString();
    }

    return ""; // If no result is found
  }

  Future<List<Map<String, dynamic>>> fetchAnnouncements(
      String courseCode, String sectionId) async {
    final db = await database;
    return await db.query(
      'Announcement',
      columns: ['Announcement_Id', 'Content', 'Upload_date', 'Upload_time'],
      where: 'Course_Code = ? AND Section_Id = ?',
      whereArgs: [courseCode, sectionId],
    );
  }
  // Fetch courses and sections taught by a teacher
  Future<List<Map<String, dynamic>>> fetchTeacherCourses(String teacherId) async {
    final db = await instance.database;
    final query = '''
  SELECT c.Course_Code, c.Course_Name, tsc.Section_Id
  FROM Teacher_Section_Course AS tsc
  JOIN Course AS c ON c.Course_Code = tsc.Course_Code
  WHERE tsc.Teacher_Id = ?
  ''';
    return await db.rawQuery(query, [teacherId]);
  }

  Future<String> getStudentSection(String studentId) async {
    final db = await instance.database;
    final result = await db.query(
      'Student',
      columns: ['Section'],
      where: 'Student_Id = ?',
      whereArgs: [studentId],
    );

    if (result.isNotEmpty) {
      return result.first['Section'] as String;
    } else {
      return '1A'; // Default section
    }
  }

  Future<List<String>> getRegisteredCourses(String studentId) async {
    final db = await instance.database;
    final result = await db.query(
      'Enrollment',
      columns: ['Course_Code'],
      where: 'Student_Id = ?',
      whereArgs: [studentId],
    );

    return result.map((row) => row['Course_Code'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> getCoursesBySection(String section) async {
    final db = await instance.database;
    final firstDigit = section.substring(0, 1);

    return await db.rawQuery('''
      SELECT c.Course_Code, c.Course_Name, c.Credit_Hrs, c.Course_Type, ts.Section_Id AS Section,u.User_Name AS Teacher_Name
      FROM Course c
      LEFT JOIN Teacher_Section_Course ts ON ts.Course_Code = c.Course_Code
      LEFT JOIN Teacher t ON ts.Teacher_Id = t.Teacher_Id
      LEFT JOIN User u ON t.User_Id = u.User_Id
      WHERE c.Semester = ? AND ts.Section_Id = ?
    ''', [firstDigit,section]);
  }

  Future<List<Map<String, dynamic>>> fetchTeachersForSection(
      String sectionId, String courseCode) async {
    final db = await instance.database;
    final query = '''
    SELECT u.User_Name AS User_Name
    FROM Teacher_Section_Course AS tsc
    JOIN Teacher AS t ON t.Teacher_Id = tsc.Teacher_Id
    JOIN User AS u ON u.User_Id = t.User_Id
    WHERE tsc.Section_Id = ? AND tsc.Course_Code = ?
  ''';
    return await db.rawQuery(query, [sectionId, courseCode]);
  }

  Future<List<Map<String, dynamic>>> fetchStudentsForSection(String sectionId,String courseCode) async {
    final db = await instance.database;
    final query = '''
    SELECT u.User_Name as User_Name, s.Student_Id as Student_Id
    FROM Enrollment AS e
    JOIN Student AS s ON s.Student_Id = e.Student_Id
    JOIN User AS u ON u.User_Id = s.User_Id
    WHERE e.Section_Id = ? AND e.Course_Code = ?
  ''';
    return await db.rawQuery(query, [sectionId,courseCode]);
  }


  Future<List<Map<String, dynamic>>> getStudentCourses(String studentId) async {
    final db = await instance.database;
    final result = await db.query('Enrollment', where: 'Student_Id = ?', whereArgs: [studentId]);
    return result;
  }
  Future<List<Map<String, dynamic>>> getRegisteredCoursesWithDetails(String studentId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT C.Course_Code, C.Course_Name, C.Credit_Hrs
      FROM Enrollment e
      INNER JOIN Course C ON e.Course_Code = C.Course_Code
      WHERE e.Student_Id = ?
    ''', [studentId]);
  }


  Future<int> calculateTotalFees(String studentId, int creditHourFee) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(C.Credit_Hrs) as Total_Credit_Hrs
      FROM Enrollment e
      INNER JOIN Course C ON e.Course_Code = C.Course_Code
      WHERE e.Student_Id = ?
    ''', [studentId]);

    int totalCreditHours = result.first['Total_Credit_Hrs'] as int ?? 0;
    return totalCreditHours * creditHourFee;
  }

  // Fetch attendance for a specific student and course
  Future<List<Map<String, dynamic>>> getAttendanceForCourse(String courseCode, String studentId) async {
    final db = await instance.database;
    final result = await db.query(
      'Attendance',
      where: 'Course_Code = ? AND Student_Id = ?',
      whereArgs: [courseCode, studentId],
      orderBy: 'Attend_Date DESC',  // Order by date descending
    );
    return result;
  }

  Future<List<Map<String, dynamic>>> fetchAttendanceForDate(
      String courseCode, String studentId, String attendDate) async {
    final db = await instance.database;
    return await db.query(
      'Attendance',
      where: 'Course_Code = ? AND Student_Id = ? AND Attend_Date = ?',
      whereArgs: [courseCode, studentId, attendDate],
    );
  }

  //Update queries

  Future<int> updateAnnouncement({
    required int announcementId,
    required String content,
    required String uploadDate,
    required String uploadTime,
  }) async {
    final db = await instance.database;
    final updateData = {
      'Content': content,
      'Upload_date': uploadDate,
      'Upload_time': uploadTime,
    };
    // Perform the update query
    return await db.update(
      'announcements', // Table name
      updateData, // Updated data
      where: 'Announcement_Id = ?', // Condition to match the announcement
      whereArgs: [announcementId], // Value for the condition
    );
  }

  Future<List<Map<String, dynamic>>> getAssignments(String courseCode, String sectionId) async {
    final db = await instance.database;
    return await db.query(
      'Assignments',
      where: 'Course_Code = ? AND Section_Id = ?',
      whereArgs: [courseCode, sectionId],
    );
  }
  //Delete queries

  Future<bool> deleteStudent(String studentId) async {
    final db = await database;
    try {
      // First, find the associated User_Id
      final studentResult = await db
          .query('Student', where: 'Student_Id = ?', whereArgs: [studentId]);

      if (studentResult.isEmpty) {
        return false; // Student not found
      }

      int userId = studentResult.first['User_Id'] as int;

      // Delete from Enrollment table first
      await db.delete('Enrollment',
          where: 'Student_Id = ?', whereArgs: [studentId]);

      // Delete from StudentAssignment table
      await db.delete('StudentAssignment',
          where: 'Student_Id = ?', whereArgs: [studentId]);

      // Delete from Student table
      await db
          .delete('Student', where: 'Student_Id = ?', whereArgs: [studentId]);

      // Delete from User table
      await db.delete('User', where: 'User_Id = ?', whereArgs: [userId]);

      return true;
    } catch (e) {
      print('Error deleting student: $e');
      return false;
    }
  }

  Future<bool> deleteTeacher(String teacherId) async {
    final db = await database;
    try {
      // First, find the associated User_Id
      final teacherResult = await db
          .query('Teacher', where: 'Teacher_Id = ?', whereArgs: [teacherId]);

      if (teacherResult.isEmpty) {
        return false; // Teacher not found
      }

      int userId = teacherResult.first['User_Id'] as int;

      // Delete from Teacher_Section_Course table first
      await db.delete('Teacher_Section_Course',
          where: 'Teacher_Id = ?', whereArgs: [teacherId]);

      await db.delete('Assignments',
          where: 'Teacher_Id = ?', whereArgs: [teacherId]);



      // Delete from Announcement table
      // await db.delete('Announcement',
      //     where: 'Teacher_Id = ?', whereArgs: [teacherId]);

      // Delete from Teacher table
      await db
          .delete('Teacher', where: 'Teacher_Id = ?', whereArgs: [teacherId]);

      // Delete from User table
      await db.delete('User', where: 'User_Id = ?', whereArgs: [userId]);
      await db.delete('Announcement', where: 'User_Id = ?', whereArgs: [userId]);
      return true;
    } catch (e) {
      print('Error deleting teacher: $e');
      return false;
    }
  }

  Future<void> deleteAnnouncement(int announcementId) async {
    final db = await database;
    await db.delete(
      'Announcement',
      where: 'Announcement_Id = ?',
      whereArgs: [announcementId],
    );
  }

  Future<void> dropCourse(String studentId,String courseCode) async {
    final db = await instance.database;

    await db.delete(
      'Enrollment',
      where: 'Course_Code = ? AND Student_Id = ?',
      whereArgs: [courseCode, studentId],
    );
  }

  Future<int> deleteAssignment(int id) async {
    final db = await instance.database;
    return await db.delete(
      'Assignments',
      where: 'Assignment_Id = ?',
      whereArgs: [id],
    );
  }

  //Validator queries

  Future<bool> teacherExists(String teacherId) async {
    final db = await database;
    final result = await db.query(
      'Teacher',
      where: 'Teacher_Id = ?',
      whereArgs: [teacherId],
    );
    return result.isNotEmpty;
  }

  Future<bool> courseExists(String courseCode) async {
    final db = await database;
    final result = await db.query(
      'Course',
      where: 'Course_Code = ?',
      whereArgs: [courseCode],
    );
    return result.isNotEmpty;
  }

  Future<bool> canAddAnnouncement(int userId) async {
    final db = await database;

    // Get the most recent announcement for the user
    final result = await db.rawQuery('''
    SELECT Upload_date, Upload_time
    FROM Announcement
    WHERE User_Id = ?
    ORDER BY datetime(Upload_date || 'T' || Upload_time) DESC
    LIMIT 1
  ''', [userId]);

    if (result.isEmpty) {
      // No announcements exist, so the user can add a new one
      return true;
    }

    // Parse the latest announcement's date and time
    final lastDate = result.first['Upload_date'] as String;
    final lastTime = result.first['Upload_time'] as String;
    final lastAnnouncement = DateTime.parse('$lastDate $lastTime');

    // Get the current time
    final now = DateTime.now();

    // Check if the difference is at least 1 minute
    return now.difference(lastAnnouncement).inSeconds >= 60;
  }

  //Helper function
  Future<void> printTableInfo(String tableName) async {
    final db = await database;
    final result = await db.rawQuery('PRAGMA table_info($tableName)');
    for (var row in result) {
      print(row);
    }
  }

  Future<List<Map<String, dynamic>>> getTableSchema(String tableName) async {
    final db = await instance.database;
    return await db.rawQuery('PRAGMA table_info($tableName)');
  }

  Future<List<Map<String, dynamic>>> getAllRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''SELECT *
       FROM Course''');

    return result;
  }
    Future<List<Map<String, dynamic>>> getAllTeacher() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''SELECT *
       FROM Teacher''');

    return result;
  }
  Future<List<Map<String, dynamic>>> getAllStudent() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''SELECT *
       FROM Student''');

    return result;
  }
}
