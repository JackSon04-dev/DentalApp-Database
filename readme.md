# TỔNG QUAN HỆ THỐNG QUẢN LÝ NHA KHOA

## 1. Mục tiêu hệ thống
Số hóa toàn diện vòng đời vận hành của phòng khám Nha khoa: từ Khâu tiếp đón, Đặt lịch, Quản trị vật tư, Thực thi lâm sàng, cho đến Kế toán tài chính.

## 2. Kiến trúc Cơ sở dữ liệu (Database)
- **Quy mô:** Gồm 22 bảng (Tables), chia thành 6 cấp độ để quản lý chặt chẽ Khóa ngoại, chống tham chiếu vòng.
- **Tiêu chuẩn thiết kế:**
  - **Chuẩn hóa 3NF tuyệt đối 100%:** Loại bỏ hoàn toàn Dữ liệu tính toán (Derived Data) và Dữ liệu dư thừa (Data Redundancy) ở mọi bảng.
  - **Bảo toàn dữ liệu bằng Snapshot Pattern:** Sử dụng cơ chế Sao chép cứng (Hard-copy) từ Danh mục sang Giao dịch lâm sàng để đảm bảo tính toàn vẹn của Dữ liệu giá cả lịch sử. Mọi biến động giá hiện tại không bao giờ làm phá vỡ các Hóa đơn trong quá khứ.
- **Tính tuân thủ Y tế (Healthcare Compliance):** Tích hợp hệ thống Vết tích (audit_log) chạy ngầm, tự động lưu vết mọi thao tác Thêm/Sửa/Xóa của toàn bộ Nhân sự trên những tính năng nghiệp vụ quan trọng của hệ thống nhằm minh bạch hóa và truy cứu trách nhiệm khi có sự cố.

## 3. Phân quyền & Chức năng (Role-Based Access Control)
Hệ thống phân chia quyền hạn thành 4 nhóm chính, mỗi nhóm được cấp các chức năng chuyên biệt:

1. **Bệnh nhân (Patient)**
   - Đăng ký và quản lý tài khoản cá nhân.
   - Đặt lịch hẹn khám online qua App, chọn Bác sĩ và Dịch vụ.
   - Xem lại lịch sử khám bệnh và chi tiết Đơn thuốc đã được kê.
   - Theo dõi tiến độ thanh toán của Phác đồ điều trị và Hóa đơn.

2. **Lễ tân / Kế toán (Receptionist / Cashier - Bảng Nhân viên)**
   - Tiếp đón bệnh nhân, kiểm tra và xác nhận Check-in để chuyển trạng thái lịch hẹn.
   - Điều phối luồng bệnh nhân vào phòng khám dựa trên lịch làm việc của Bác sĩ.
   - Tạo, chỉnh sửa và xuất Hóa đơn thanh toán.
   - Áp dụng các mã Khuyến mãi và xác nhận thanh toán hóa đơn.

3. **Nha sĩ (Dentist)**
   - Xem danh sách bệnh nhân và lịch hẹn khám trong ca làm việc của mình.
   - Thực hiện khám bệnh, chỉ định Dịch vụ điều trị và Vật tư sử dụng (ghi nhận vào Hồ sơ bệnh án).
   - Thiết lập Phác đồ điều trị dài hạn, phân bổ các Giai đoạn phác đồ và cập nhật tiến độ (có thể chèn thêm giai đoạn phát sinh nếu cần).
   - Kê Đơn thuốc và chi tiết từng loại thuốc cho bệnh nhân.

4. **Quản lý / Admin (Manager)**
   - Quản lý toàn bộ Danh mục hệ thống: Dịch vụ, Sản phẩm (Vật tư), Phác đồ mẫu, Khuyến mãi.
   - Phân công Ca làm việc cho Nha sĩ và chỉ định Phòng điều trị.
   - Quản trị Kho vật tư: Cập nhật số lượng tồn kho.
   - Tạo mới và phân quyền Tài khoản cho toàn bộ nhân sự trong phòng khám.
   - Xem báo cáo tài chính tổng hợp và theo dõi lịch sử hệ thống qua bảng Audit Log.

## 4. Bản đồ Luồng nghiệp vụ (Business Flow)
Hệ thống được chia thành 5 luồng vận hành xương sống:

---

### LUỒNG 1: QUẢN LÝ ĐỊNH DANH VÀ HỒ SƠ Y TẾ (User & Profile Flow)
**Bảng liên quan (5 bảng):** Tài khoản, Bệnh nhân, Nhân viên, Nha sĩ, Audit Log (chạy ngầm)

- **Quy trình:** Khách hàng đăng ký App → Tạo tài khoản (Auth) → Thêm thông tin bệnh nhân (Profile). Đối với Nhân sự, Admin tạo tài khoản → Phân quyền → Tạo nha sĩ hoặc nhân viên. 

---

### LUỒNG 2: QUẢN LÝ DANH MỤC VÀ VẬT TƯ Y TẾ (Catalog & Master Data)
Mục đích của luồng này là thiết lập toàn bộ "Tài nguyên nền tảng" (Master Data) để Bác sĩ có thể lấy ra sử dụng trong lúc khám bệnh.

**Bảng liên quan (5 bảng):** Dịch vụ, Chi tiết dịch vụ, Phác đồ mẫu, Chi tiết phác đồ mẫu, Sản phẩm, Khuyến mãi

1. **Kịch bản vận hành:**
   - **Cấu hình Dịch vụ:** Quản lý tạo dịch vụ cha tại bảng Dịch vụ. Sau đó, sinh ra các gói con tại bảng Chi tiết dịch vụ. Mối quan hệ là 1:N.
   - **Cấu hình Phác đồ mẫu:** Để bác sĩ không phải gõ tay nhiều lần, Quản lý tạo sẵn Template tại bảng Phác đồ mẫu. Sau đó gán các công đoạn vào Chi tiết phác đồ mẫu.
   - **Thiết lập Khuyến mãi:** Quản lý tạo sẵn các chương trình giảm giá (voucher, % discount) lưu vào bảng Khuyến mãi để Lễ tân áp dụng khi xuất hóa đơn.
   - **Quản lý tồn kho thủ công:** Quản lý tạo danh mục vật tư tại bảng Sản phẩm và chủ động cập nhật trực tiếp (CRUD) số lượng tồn kho trên phần mềm.

---

### LUỒNG 3: ĐIỀU PHỐI LỊCH HẸN VÀ CHECK-IN (Appointment Flow)
**Bảng liên quan (5 bảng):** Phòng điều trị, Nha sĩ, Ca làm việc, Lịch hẹn, Bệnh nhân, Dịch vụ

1. **Kịch bản vận hành:**
   - **Bước 1 (Đăng ký làm việc):** Bác sĩ đăng ký lịch làm việc. Quản lý phân công Ca làm việc: phòng nào, ngày nào, từ mấy giờ đến mấy giờ.
   - **Bước 2 (Tìm giờ và Đặt lịch):** Bệnh nhân lên App chọn Dịch vụ và Bác sĩ. Hệ thống quét dữ liệu tìm giờ trống để chống trùng lịch (Overlap). Khách bấm đặt → Insert dữ liệu vào Lịch hẹn.
   - **Bước 3 (Check-in):** Khách đến phòng khám, Lễ tân phần mềm biết Bác sĩ đang ngồi ở phòng nào để mời khách vào. Trạng thái lịch hẹn chuyển thành dang_kham.

---

### LUỒNG 4: THỰC THI LÂM SÀNG TẠI PHÒNG KHÁM (Medical Execution Flow)
**Bảng liên quan (8 bảng):** Lịch hẹn, Hồ sơ bệnh án, Dịch vụ điều trị, Vật tư sử dụng, Đơn thuốc, Chi tiết đơn thuốc, Phác đồ điều trị, Giai đoạn phác đồ.

1. **Kịch bản vận hành:** 
   Bác sĩ tiếp nhận Lịch hẹn đang khám → Hệ thống tự sinh Hồ sơ bệnh án. Tùy tình huống sẽ rẽ làm 2 kịch bản:

   - **Kịch bản 4A: Khám lẻ / Chữa bệnh ngay**
     - Bác sĩ tiến hành làm dịch vụ gì → Nhập vào bảng Dịch vụ điều trị.
     - Tiêu hao vật tư gì → Nhập vào bảng Vật tư sử dụng (Hệ thống tự động trừ số lượng tồn).
     - Bác sĩ tạo phiếu Đơn thuốc, sau đó kê chi tiết từng loại thuốc (liều lượng, cách uống) vào bảng Chi tiết đơn thuốc.
     
   - **Kịch bản 4B: Khám tư vấn và Lập kế hoạch dài hạn**
     - Bác sĩ tạo một Phác đồ điều trị mới. Gọi Template từ Phác đồ mẫu để sinh ra các công đoạn lưu vào bảng Giai đoạn phác đồ.
     - Chốt giá trị Hợp đồng điều trị với khách thông qua chọn chi tiết các loại dịch vụ, vật tư cho các giai đoạn. Hệ thống cộng tổng chi phí lại cho từng giai đoạn (Ghi cứng "Tổng chi phí").
     - Tại đây, hệ thống hỗ trợ setup cấu hình thanh toán theo 2 cách (Link trực tiếp sang Kịch bản 5B của Luồng Kế toán):
       - **Thanh toán trọn gói 1 lần (Pay all package)**
       - **Thanh toán theo từng giai đoạn (Pay per period)**
     - Lưu ý nếu phát sinh thêm giai đoạn bất chợt thì cập nhật thêm vào giai đoạn của phác đồ với khóa ngoại là id của giai đoạn trước đó.

---

### LUỒNG 5: THANH TOÁN VÀ XUẤT HÓA ĐƠN (Billing & Finance Flow)
**Bảng liên quan (4 bảng):** Hóa đơn, Lịch hẹn, Phác đồ điều trị, Khuyến mãi.
*(Lưu ý: Hệ thống áp dụng chính sách "Clear cut" - Thanh toán đứt điểm 100% trên mỗi hóa đơn, không áp dụng cho nợ/trả góp một phần).*

1. **Kịch bản vận hành chuẩn:** 
   Cuối buổi khám, Lễ tân mở phần mềm xuất Hóa đơn. Tùy theo thỏa thuận mà có 2 trường hợp:

   - **Kịch bản 5A: Thu tiền lẻ (Pay-as-you-go)**
     - Dành cho khách làm Kịch bản 4A. Hóa đơn sẽ tự động lấy số liệu tính TỔNG (SUM) từ Dịch vụ điều trị và Vật tư sử dụng trong buổi khám. Lễ tân có thể gán thêm mã Khuyến mãi để giảm trừ. Khách đóng 100% tiền → Hóa đơn chuyển trạng thái "Đã thanh toán".
     
   - **Kịch bản 5B: Thu tiền Phác đồ (Pay all or Pay per period)**
     - Dành cho khách làm Kịch bản 4B. Tùy theo thỏa thuận ban đầu:
       - **Nếu trả trọn gói:** Lễ tân xuất 1 Hóa đơn tổng thu toàn bộ giá trị Phác đồ. Khi thu tiền xong, Backend tự động cập nhật TOÀN BỘ các Giai đoạn phác đồ thành trạng thái "Đã thanh toán".
       - **Nếu trả theo tiến độ (Pay per period):** Khách đến làm Giai đoạn nào, Lễ tân xuất Hóa đơn thu đúng bằng số tiền quy định của Giai đoạn đó. Backend cập nhật riêng Giai đoạn đó thành "Đã thanh toán".
     - Nhờ vậy, ở các lần tái khám, khách đến làm dịch vụ thuộc Phác đồ đã trả tiền sẽ không bị tính phí nữa.