# Post Status Constants

This document explains how to use the post status constants and widgets in the Flutter app.

## Post Status Values

The app supports 4 post statuses:

| Value | Name        | Display Name | Description                                |
| ----- | ----------- | ------------ | ------------------------------------------ |
| 0     | NotReceived | Chưa nhận    | Post has not been received by any designer |
| 1     | Received    | Đã nhận      | Post has been received by a designer       |
| 2     | Completed   | Hoàn thành   | Post has been completed                    |
| 3     | Locked      | Đã khóa      | Post has been locked                       |

## Usage

### 1. Using PostStatus Enum

```dart
import '../constants/post_status_constants.dart';

// Get status from integer value
PostStatus status = PostStatus.fromValue(1); // Returns PostStatus.received

// Get status from string name
PostStatus status = PostStatus.fromName('Completed'); // Returns PostStatus.completed

// Access properties
print(status.displayName); // "Đã nhận"
print(status.color); // Color object
print(status.backgroundColor); // Color object
print(status.icon); // IconData object
```

### 2. Using PostStatusBadge Widget

```dart
import '../widgets/post_status_badge.dart';

// Basic usage
PostStatusBadge(postStatus: 1)

// With custom styling
PostStatusBadge(
  postStatus: post['postStatus'],
  fontSize: 12,
  iconSize: 14,
  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  showIcon: true,
)
```

### 3. Handling Different Data Types

The widgets handle both integer and string status values:

```dart
// Integer value from API
PostStatusBadge(postStatus: 2)

// String value from API
PostStatusBadge(postStatus: 'Completed')

// Both will display the same badge
```

## Colors and Icons

Each status has predefined colors and icons:

- **NotReceived (0)**: Gray color with schedule icon
- **Received (1)**: Blue color with check_circle_outline icon
- **Completed (2)**: Green color with task_alt icon
- **Locked (3)**: Red color with lock icon

## Example Implementation

```dart
class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Post content...

          // Status badge
          PostStatusBadge(
            postStatus: post['postStatus'],
            fontSize: 11,
            iconSize: 13,
          ),
        ],
      ),
    );
  }
}
```
