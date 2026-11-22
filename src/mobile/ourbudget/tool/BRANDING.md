# Tài nguyên thương hiệu OurBudget

Nguồn duy nhất: `assets/icons/our-budget-wordmark.svg`. Không vẽ lại hoặc thay màu chữ O. Script lấy nguyên hai circle đầu của SVG, giữ stroke, bán kính và opacity; đặt tâm vào canvas vuông. Không lấy phần chữ còn lại vào launcher.

Từ thư mục Flutter:

```powershell
python -m pip install -r tool/requirements-brand.txt
python tool/generate_brand_assets.py
flutter pub get
flutter test
flutter analyze
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Logo giao diện có PNG 1x và 4x xuất trực tiếp từ các path SVG, không thêm dependency Flutter. AppBar chung của AuthPage hiển thị 204x48 trong thanh cao 72, căn giữa, có nhãn OurBudget cho trình đọc màn hình; cùng áp dụng cho đăng nhập, đăng ký, quên/đặt lại mật khẩu. Image BoxFit.contain giữ tỷ lệ khi chiều rộng khả dụng nhỏ hơn 204.

Android: 5 mật độ mipmap 48/72/96/144/192; adaptive icon API26+ có nền trắng và foreground trong vùng an toàn 60/108. `icon` và `roundIcon` đều trỏ tới ic_launcher; hệ điều hành tự áp mask. Không thay màu nhận diện để tạo monochrome icon.

iOS: asset catalog AppIcon được khai báo cho Debug/Profile/Release trong Runner.xcodeproj; tất cả slot iPhone/iPad/marketing được xuất từ cùng chữ O. PNG nền trắng, RGB không alpha, có bản 1024x1024. Thư mục ios được tạo bằng Flutter SDK của dự án vì trước đây chỉ có Android. Tên hiển thị OurBudget, bundle ID com.ourbudget.ourbudget.

Build iOS phải thực hiện trên macOS/Xcode với provisioning phù hợp. Chưa nghiệm thu iOS, ký phát hành hoặc Google OAuth iOS; cấu hình client iOS/URL scheme phải được thiết lập trước khi thử Google trên iPhone. Không suy ra khả năng chạy toàn bộ app iOS chỉ từ asset catalog.

Không thay đổi SVG nguồn khi chỉnh kích thước launcher. Khi logo nguồn thay đổi cấu trúc, script dừng bằng assert để tránh trích nhầm ký tự. Không uninstall/clear data chỉ để cập nhật icon; cài APK bằng `adb install -r`. Nếu launcher giữ cache, đóng/mở launcher trước khi đánh giá icon.
