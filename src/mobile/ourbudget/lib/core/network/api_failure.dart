enum ApiFailure {
  sessionExpired('Phiên đã hết hạn. Vui lòng đăng nhập lại.'),
  notFound('Không tìm thấy dữ liệu yêu cầu.'),
  conflict('Dữ liệu đã thay đổi. Hãy làm mới và thử lại.'),
  invalidInput('Hãy kiểm tra lại thông tin đã nhập.'),
  unavailable('Không thể tải dữ liệu. Hãy thử lại.');

  const ApiFailure(this.message);
  final String message;

  static ApiFailure fromStatus(int status) => switch (status) {
    401 => sessionExpired,
    404 => notFound,
    409 => conflict,
    422 => invalidInput,
    _ => unavailable,
  };
}
