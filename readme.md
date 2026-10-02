# TỔNG QUAN HỆ THỐNG QUẢN LÝ NHA KHOA

## 1. Mục tiêu hệ thống
Số hóa toàn diện vòng đời vận hành của phòng khám Nha khoa: từ Khâu tiếp đón, Đặt lịch, Quản trị kho vật tư, Thực thi lâm sàng, cho đến Kế toán tài chính.

## 2. Kiến trúc Cơ sở dữ liệu (Database)
- **Quy mô:** Gồm 26 bảng (Tables), chia thành 6 cấp độ để quản lý chặt chẽ Khóa ngoại, chống tham chiếu vòng.
- **Tiêu chuẩn thiết kế:**
  - **Chuẩn hóa 3NF tuyệt đối 100%:** Loại bỏ hoàn toàn Dữ liệu tính toán (Derived Data) và Dữ liệu dư thừa (Data Redundancy) ở mọi bảng.
  - **Bảo toàn dữ liệu bằng Snapshot Pattern:** Sử dụng cơ chế Sao chép cứng (Hard-copy) từ Danh mục sang Giao dịch lâm sàng để đảm bảo tính toàn vẹn của Dữ liệu giá cả lịch sử. Mọi biến động giá hiện tại không bao giờ làm phá vỡ các Hóa đơn trong quá khứ.

## 3. Bản đồ Luồng nghiệp vụ (Business Flow)
Hệ thống được chia thành 5 luồng vận hành xương sống:

---

### LUỒNG 1: QUẢN LÝ ĐỊNH DANH VÀ HỒ SƠ Y TẾ (User & Profile Flow)
**Bảng liên quan (4 bảng):** Tài khoản, Bệnh nhân, Nhân viên, Nha sĩ

- **Quy trình:** Khách hàng đăng ký App → Tạo tài khoản (Auth) → Thêm thông tin bệnh nhân (Profile). Đối với Nhân sự, Admin tạo tài khoản → Phân quyền → Tạo nha sĩ hoặc nhân viên.

---

### LUỒNG 2: QUẢN LÝ DANH MỤC VÀ QUẢN TRỊ KHO (Catalog & Inventory)
Mục đích của luồng này là thiết lập toàn bộ "Tài nguyên nền tảng" (Master Data) để Bác sĩ có thể lấy ra sử dụng trong lúc khám bệnh. Luồng này được chia làm 3 phân hệ nhỏ:

#### Luồng 2.1: Quản trị Danh mục Y tế và Phác đồ mẫu
**Bảng liên quan (4 bảng):** Dịch vụ, Chi tiết dịch vụ, Phác đồ mẫu, Chi tiết phác đồ mẫu

1. **Kịch bản vận hành:**
   - **Cấu hình Dịch vụ:** Quản lý tạo dịch vụ cha tại bảng Dịch vụ (VD: "Bọc Răng Sứ"). Sau đó, sinh ra các gói con tại bảng Chi tiết dịch vụ (VD: "Sứ Titan - 2tr", "Sứ Zirconia - 4tr"). Mối quan hệ là 1:N.
   - **Cấu hình Phác đồ mẫu:** Để bác sĩ không phải gõ tay nhiều lần, Quản lý tạo sẵn Template tại bảng Phác đồ mẫu (VD: "Trồng Implant 3 bước"). Sau đó gán các công đoạn vào Chi tiết phác đồ mẫu. 

#### Luồng 2.2: Quản lý Đối tác và Hàng hóa (N-N Relationship)
**Bảng liên quan (3 bảng):** Nhà cung cấp, Sản phẩm, Sản phẩm nhà cung cấp

1. **Kịch bản vận hành:**
   - Quản lý kho tạo hồ sơ hàng hóa tại bảng Sản phẩm (VD: Găng tay, Thuốc tê, Mão sứ).
   - Hệ thống hỗ trợ xử lý thực tế: Một loại sản phẩm có thể được mua từ Cty A hoặc Cty B. Ngược lại, Cty A có thể bán hàng chục loại vật tư.
   - Đây là mối quan hệ N:N, được hóa giải thông qua bảng trung gian Sản phẩm nhà cung cấp.

#### Luồng 2.3: Nghiệp vụ Nhập Kho Inbound và Kiểm soát Tồn kho
**Bảng liên quan (4 bảng):** Phiếu nhập kho, Chi tiết nhập kho, Sản phẩm, Nhân viên

1. **Kịch bản vận hành:**
   - **Bước 1 (Lập phiếu):** Nhân viên kho lập Phiếu nhập kho.
   - **Bước 2 (Ghi chi tiết):** Quét mã vạch lô hàng mới, đẩy dữ liệu vào Chi tiết nhập kho lưu rõ số lượng, đơn giá nhập, số lô, hạn sử dụng.
   - **Bước 3 (Phê duyệt):** Quản lý kho đăng nhập, duyệt phiếu. ID của Quản lý được ghi vào cột người duyệt phiếu.
   - **Bước 4 (Cập nhật tồn kho):** Backend kích hoạt Trigger/Logic cộng dồn số lượng vừa nhập vào cột số lượng tồn bên bảng Sản phẩm.

---

### LUỒNG 3: ĐIỀU PHỐI LỊCH HẸN VÀ CHECK-IN (Appointment Flow)
**Bảng liên quan (5 bảng):** Phòng điều trị, Nha sĩ, Ca làm việc, Lịch hẹn, Bệnh nhân, Dịch vụ

1. **Kịch bản vận hành:**
   - **Bước 1 (Đăng ký làm việc):** Bác sĩ đăng ký lịch làm việc. Quản lý thêm dữ liệu vào bảng Ca làm việc: nha sĩ đó làm ở phòng nào, ngày nào, từ mấy giờ đến mấy giờ.
   - **Bước 2 (Tìm giờ và Đặt lịch):** Bệnh nhân lên App chọn Dịch vụ và Bác sĩ. Backend quét dữ liệu tìm giờ trống. Khách bấm đặt → Insert dữ liệu vào bảng Lịch hẹn.
   - **Bước 3 (Check-in):** Khách đến phòng khám, Lễ tân nhìn vào phần mềm biết Bác sĩ đang ngồi ở phòng nào để mời khách vào. Trạng thái lịch hẹn chuyển thành dang_kham.

2. **Phân tích Logic Database:**
   - **Bài toán 1:** Làm sao hệ thống biết Bác sĩ rảnh? Bằng cách nào chặn đặt trùng giờ? Khi khách hàng bấm vào Bác sĩ A ngày 20/10, Backend sẽ xử lý qua 2 lớp chặn:
     - **Lớp 1 (Kiểm tra Ca):** Lấy ngày 20/10 truy vấn vào bảng Ca làm việc. Nếu Bác sĩ A có ca (ví dụ: 08:00 - 12:00), hệ thống mới cho phép đi tiếp. Nếu bảng này trống nghĩa là Bác sĩ nghỉ.
     - **Lớp 2 (Trừ hao thời gian):** Backend truy vấn tiếp vào bảng Lịch hẹn của Bác sĩ A trong ngày 20/10. Hệ thống sẽ quét qua cột giờ hẹn và giờ kết thúc dự kiến của các khách hàng trước. Những "Slot" còn thừa lại mới được đẩy lên App cho khách đặt.

---

### LUỒNG 4: THỰC THI LÂM SÀNG TẠI PHÒNG KHÁM (Medical Execution Flow)
**Bảng liên quan (7 bảng):** Lịch hẹn, Hồ sơ bệnh án, Dịch vụ điều trị, Vật tư sử dụng, Đơn thuốc, Phác đồ điều trị, Giai đoạn phác đồ.

1. **Kịch bản vận hành:** 
   Bác sĩ tiếp nhận Lịch hẹn đang khám → Hệ thống tự sinh một Hồ sơ bệnh án đại diện cho buổi hôm đó. Từ đây rẽ làm 2 kịch bản:

   - **Kịch bản 4A: Khám lẻ / Chữa bệnh ngay (Trám răng, nhổ răng...)**
     - Bác sĩ tiến hành làm dịch vụ gì → Nhập vào bảng Dịch vụ điều trị.
     - Tiêu hao vật tư gì (Mắc cài, thuốc tê...) → Bắn mã vạch lưu vào bảng Vật tư sử dụng (Backend đồng thời trừ số lượng tồn kho).
     - Bác sĩ kê thuốc cho khách về nhà uống → Ghi vào bảng Đơn thuốc.
     
   - **Kịch bản 4B: Khám tư vấn và Lập kế hoạch dài hạn (Niềng răng, Trồng Implant...)**
     - Bác sĩ không chữa ngay mà tạo một Phác đồ điều trị mới.
     - Gọi Template mẫu từ danh mục Phác đồ mẫu để sinh nhanh ra 3-4 công đoạn và chọn vật tư theo nhu cầu bệnh nhân, lưu vào bảng Giai đoạn phác đồ.
     - Chốt giá trị Hợp đồng điều trị với khách (Ghi cứng cột "Tổng chi phí" của Phác đồ).
     - Tại đây, tùy thuộc vào năng lực tài chính của khách hàng, Lễ tân/Bác sĩ sẽ thiết lập cấu hình thanh toán rẽ nhánh theo 2 điều kiện (Conditions):
       - **Điều kiện 4B.1 - Thanh toán trọn gói 1 lần (Pay all package):** Khách hàng đồng ý thanh toán toàn bộ Hợp đồng điều trị ngay trong hôm nay. 
       - **Điều kiện 4B.2 - Thanh toán theo từng giai đoạn (Pay per process):** Khách hàng muốn trả dần theo tiến độ dựa trên từng Giai đoạn phác đồ (Ví dụ: Giai đoạn 1 tổng tiền 10 triệu, Giai đoạn 2 tổng tiền 5 triệu...). Sau này, bệnh nhân tái khám và hoàn thành đến công đoạn nào, hệ thống sẽ chốt đơn để xuất Hóa đơn thu tiền tương ứng với con số của giai đoạn đó.

---

### LUỒNG 5: THANH TOÁN VÀ XUẤT HÓA ĐƠN (Billing & Finance Flow)
**Bảng liên quan (4 bảng):** Hóa đơn, Thanh toán, Lịch hẹn, Phác đồ điều trị.

1. **Kịch bản vận hành chuẩn:** 
   Cuối buổi khám, Lễ tân mở Lịch hẹn lên để xuất Hóa đơn. Tùy theo thỏa thuận mà có các trường hợp sau:

   - **Kịch bản 5A: Thu tiền lẻ (Pay-as-you-go)**
     - Dành cho khách làm Kịch bản 4A. Hóa đơn sẽ tự động lấy số liệu tính TỔNG (SUM) từ 2 bảng Dịch vụ điều trị và Vật tư sử dụng nằm trong Hồ sơ bệnh án của buổi khám hôm đó.
     
   - **Kịch bản 5B: Trả trọn gói Phác đồ (Package Deal)**
     - Bệnh nhân chốt mua Gói Niềng Răng 40 triệu đồng. Lễ tân xuất Hóa đơn (Lúc này Hóa đơn sẽ gán Khóa ngoại với cả Lịch hẹn của ngày hôm nay và cái Phác đồ điều trị vừa lập).
     - Số tiền 40 triệu được lấy thẳng từ cột "Tổng chi phí" của Phác đồ thay vì lấy từ Dịch vụ lẻ.
     - Khi Hóa đơn 40 triệu này được thu tiền xong → Backend tự động cập nhật TOÀN BỘ các Giai đoạn phác đồ thành trạng thái "Đã thanh toán". Nhờ vậy, ở các lần tái khám hàng tháng sau này, khách đến làm dịch vụ sẽ không hề phát sinh thêm tiền phí chữa bệnh nữa.
     
   - **Kịch bản 5C: Khách nợ tiền / Trả bằng nhiều phương thức**
     - Tổng hóa đơn là 20 triệu. Bệnh nhân trả 10 triệu bằng Tiền mặt, và 5 triệu bằng Quẹt thẻ (Còn nợ 5 triệu).
     - Lễ tân tạo 2 dòng dữ liệu ghi nhận vào bảng Thanh toán. Hệ thống tự động lấy Tổng hóa đơn trừ đi số tiền đã trả, và chốt lại công nợ báo cho khách.