# Phát hiện Cơn Động kinh Tự động từ Tín hiệu EEG Ngắn hạn

## Giới thiệu
Dự án này tập trung vào việc phát triển một hệ thống học máy tự động để nhận diện **cơn động kinh** từ các đoạn **tín hiệu điện não đồ (EEG)** ngắn hạn. Bằng cách sử dụng các thuật toán phân loại và kỹ thuật giảm chiều, mục tiêu của chúng tôi là tạo ra một mô hình hiệu quả, chính xác, nhằm hỗ trợ các chuyên gia y tế trong việc chẩn đoán và theo dõi bệnh động kinh một cách khách quan và nhanh chóng hơn.

---

## Bài toán và Mục tiêu
Việc phân tích tín hiệu EEG thủ công tốn nhiều thời gian và mang tính chủ quan. Dự án này nhằm giải quyết những thách thức đó bằng cách:
* **Xác định** liệu các đặc trưng được trích xuất từ miền thời gian, tần số và wavelet có đủ khả năng để phân biệt trạng thái **co giật (seizure)** và **không co giật (non-seizure)**.
* **Phân tích** ảnh hưởng của các kỹ thuật giảm chiều như **Phân tích Thành phần Chính (PCA)** đến hiệu suất của mô hình.
* **Xây dựng và so sánh** các mô hình phân loại để tìm ra phương pháp hiệu quả nhất cho việc phát hiện cơn động kinh.

---

## Dữ liệu
https://www.kaggle.com/datasets/yasserhessein/epileptic-seizure-recognition/data

Dự án sử dụng bộ dữ liệu công khai **"Epileptic Seizure Recognition"** từ nền tảng Kaggle.
* **Nguồn gốc:** Bộ dữ liệu này được tạo ra từ dữ liệu gốc của Andrzejak et al. (2001), bao gồm các tín hiệu EEG từ bệnh nhân động kinh và người tình nguyện khỏe mạnh.
* **Cấu trúc:** Tệp dữ liệu `epilepsy.csv` bao gồm **11,500 mẫu** (hàng).
    * Mỗi mẫu là một đoạn tín hiệu EEG dài **1 giây** (178 điểm dữ liệu).
    * **178 cột đặc trưng** (`X1` đến `X178`) đại diện cho các giá trị điện thế của tín hiệu.
    * **1 cột nhãn** (`y`) từ 1 đến 5, được chuyển đổi thành bài toán phân loại nhị phân (**1** cho **Seizure** và **0** cho **Non-Seizure**).

---

## Phương pháp Luận
Quy trình nghiên cứu của chúng tôi bao gồm bốn giai đoạn chính:

1.  **Tiền xử lý Dữ liệu:** Chuyển đổi bài toán đa lớp sang phân loại nhị phân (Seizure vs. Non-seizure) và xử lý dữ liệu bị mất cân bằng lớp bằng kỹ thuật **SMOTE**.
2.  **Trích xuất Đặc trưng (Feature Engineering):** Tính toán các đặc trưng thống kê (trung bình, độ lệch chuẩn, v.v.), năng lượng các dải tần số (Delta, Theta, Alpha, Beta, Gamma) và các hệ số từ phép biến đổi wavelet.
3.  **Giảm chiều và Phân tích Khám phá:** Sử dụng **Phân tích Thành phần Chính (PCA)** để giảm số chiều của dữ liệu, kết hợp với các phương pháp trực quan hóa như **t-SNE** và **UMAP** để đánh giá khả năng phân tách của các đặc trưng.
4.  **Xây dựng và Đánh giá Mô hình:** So sánh hiệu suất của các thuật toán phân loại như **Hồi quy Logisitc**, **Support Vector Machine (SVM)** và **Random Forest** thông qua **Cross-Validation 10 lần** để đảm bảo tính ổn định.

---

## Cài đặt và Chạy Dự án
Để chạy dự án, bạn cần cài đặt các thư viện Python sau:
```bash
pip install numpy pandas scikit-learn matplotlib seaborn
