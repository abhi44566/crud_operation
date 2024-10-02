class Note {
  int? _id; // Make _id nullable
  String? _title; // Make _title nullable
  String? _description; // Make _description nullable
  late String _date; // Use late for _date to ensure it's initialized before use
  late int _priority;

   // Use late for _priority to ensure it's initialized before use

  // Constructor without id
  Note(this._title, this._date, this._priority, [this._description]) {
    if (_title == null || _title!.length > 255) {
      throw ArgumentError('Title must be less than 256 characters');
    }
    if (_description != null && _description!.length > 255) {
      throw ArgumentError('Description must be less than 256 characters');
    }
  }

  // Constructor with id
  Note.withId(this._id, this._title, this._date, this._priority, [this._description]) {
    if (_title == null || _title!.length > 255) {
      throw ArgumentError('Title must be less than 256 characters');
    }
    if (_description != null && _description!.length > 255) {
      throw ArgumentError('Description must be less than 256 characters');
    }
  }

  // Getters
  int? get id => _id; // Nullable getter
  String? get title => _title; // Nullable getter
  String? get description => _description; // Nullable getter
  int get priority => _priority;
  String get date => _date;

  // Setters
  set title(String? newTitle) {
    if (newTitle != null && newTitle.length <= 255) {
      _title = newTitle;
    } else {
      throw ArgumentError('Title must be less than 256 characters');
    }
  }

  set description(String? newDescription) {
    if (newDescription != null && newDescription.length <= 255) {
      _description = newDescription;
    } else {
      throw ArgumentError('Description must be less than 256 characters');
    }
  }

  set priority(int newPriority) {
    if (newPriority >= 1 && newPriority <= 3) {
      _priority = newPriority;
    } else {
      throw ArgumentError('Priority must be either 1, 2, or 3');
    }
  }

  set date(String newDate) {
    _date = newDate;
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id; // Use null check for id
    }
    map['title'] = _title;
    map['description'] = _description;
    map['priority'] = _priority;
    map['date'] = _date;
    return map;
  }

  // Extract a Note object from a Map object
  Note.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'] ?? ''; // Default to empty string if null
    this._description = map['description'] ?? ''; // Default to empty string if null
    this._priority = map['priority'];
    this._date = map['date'];
  }
}
