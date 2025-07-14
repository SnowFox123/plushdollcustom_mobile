# Tính năng Delivery - Đơn giao hàng

## Mô tả

Tính năng này cho phép người dùng xem danh sách các đơn giao hàng và chi tiết của từng đơn hàng.

## Cách sử dụng

### 1. Truy cập tính năng

- Vào màn hình Profile
- Nhấn vào icon "Delivering" (index 2) trong phần "Đơn mua"
- Ứng dụng sẽ chuyển đến màn hình danh sách đơn giao hàng

### 2. Màn hình danh sách đơn giao hàng

- Hiển thị tất cả đơn giao hàng của người dùng
- Mỗi card hiển thị:
  - Mã đơn hàng (orderCode)
  - Mã giao hàng (deliveryId)
  - Trạng thái (với màu sắc và icon)
  - Thông tin người gửi và người nhận
  - Phí giao hàng
  - Ngày tạo đơn hàng
  - Ghi chú (nếu có)

### 3. Xem chi tiết đơn hàng

- Nhấn vào bất kỳ card đơn hàng nào
- Màn hình chi tiết sẽ hiển thị:
  - Thông tin đơn hàng (mã đơn, mã giao hàng, trạng thái, phí giao hàng)
  - Thông tin người gửi
  - Thông tin người nhận
  - Thời gian giao hàng (nếu đã giao)
  - Ghi chú (nếu có)

## Các trạng thái đơn hàng

| Trạng thái  | Màu sắc    | Icon                 | Mô tả             |
| ----------- | ---------- | -------------------- | ----------------- |
| ReadyToPick | Xanh dương | check_circle_outline | Sẵn sàng lấy hàng |
| Picked      | Tím        | local_shipping       | Đã lấy hàng       |
| Delivering  | Chàm       | local_shipping       | Đang giao         |
| Delivered   | Xanh lá    | done_all             | Đã giao           |
| Cancelled   | Đỏ         | cancel               | Đã hủy            |
| Failed      | Đỏ         | error                | Thất bại          |

## API Endpoints

### 1. Lấy danh sách đơn giao hàng

```
GET /delivery/token?page={page}&size={size}
```

### 2. Lấy chi tiết đơn giao hàng

```
GET /delivery/delivery-detail?DeliveryID={deliveryId}
```

## Cấu trúc dữ liệu

### Delivery Model

```dart
class Delivery {
  final String deliveryId;
  final String orderId;
  final String senderName;
  final String receiverName;
  final String orderCode;
  final double deliveryPrice;
  final String? note;
  final String deliveryStatus;
  final String createdAt;
  final String? deliveredAt;
}
```

## Tính năng bổ sung

### 1. Pull to Refresh

- Kéo xuống để làm mới danh sách đơn hàng

### 2. Error Handling

- Hiển thị thông báo lỗi khi không thể tải dữ liệu
- Nút "Thử lại" để load lại dữ liệu

### 3. Loading States

- Hiển thị loading indicator khi đang tải dữ liệu
- Skeleton loading cho trải nghiệm mượt mà

### 4. Empty State

- Hiển thị thông báo khi không có đơn giao hàng nào

## Files đã tạo/cập nhật

### Models

- `lib/models/delivery.dart` - Model cho dữ liệu delivery

### Screens

- `lib/screens/delivery_list_screen.dart` - Màn hình danh sách đơn giao hàng
- `lib/screens/delivery_detail_screen.dart` - Màn hình chi tiết đơn giao hàng

### Widgets

- `lib/widgets/delivery_status_chip.dart` - Widget hiển thị trạng thái

### Services

- `lib/services/delivery_service.dart` - Service gọi API delivery

### Cập nhật

- `lib/screens/profile_screen.dart` - Thêm navigation đến delivery screen
