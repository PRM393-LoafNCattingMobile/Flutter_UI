class AppStrings {
  const AppStrings._();

  static const appTitle = "Loaf'NCatting";
  static const loginIdentityLabel = 'Địa chỉ email hoặc số điện thoại';
  static const loginIdentityHint = 'Nhập địa chỉ email hoặc số điện thoại';
  static const passwordLabel = 'Mật khẩu';
  static const passwordHint = 'Nhập mật khẩu';
  static const forgotPassword = 'Quên mật khẩu?';
  static const signInButton = 'Đăng nhập';
  static const registerButton = 'Đăng ký';
  static const createAccountButton = 'Tạo tài khoản';
  static const createAccountTitle = 'Tạo tài khoản';
  static const loginFooterTagline = 'Cà phê ngon. Mèo xịn.';
  static const loginHeroBadge = 'Cà phê mèo và món ngon';
  static const loginDividerLabel = 'hoặc';
  static const registerHeroTitle = 'Tham gia cùng quán';
  static const registerHeroSubtitle =
      'Đặt món nhanh hơn, giữ chỗ ấm cúng và gặp gỡ các bé mèo.';
  static const registerHelperText =
      'Hồ sơ của bạn giúp quản lý đơn hàng và lượt đặt bàn ở cùng một nơi.';
  static const verificationCodeLabel = 'Mã xác minh email';
  static const verificationCodeHint = 'Nhập 6 số vừa nhận được';
  static const verifyEmailButton = 'Xác minh email';
  static const resendVerificationButton = 'Gửi lại mã';
  static const verificationCardTitle = 'Kiểm tra email của bạn';
  static const verificationCardSubtitle =
      'Nhập mã xác minh vừa được gửi để hoàn tất tạo tài khoản.';
  static const verificationSuccessMessage =
      'Xác minh thành công, chào mừng bạn đến với quán!';
  static const resendVerificationSuccessMessage = 'Đã gửi lại mã xác minh mới.';
  static const verificationCodeRequiredMessage =
      'Vui lòng nhập mã xác minh email.';
  static String verificationEmailSentTo(String email) =>
      'Mã xác minh đã được gửi đến $email';
  static String verificationExpiresAt(DateTime expiresAtLocal) {
    final hour = expiresAtLocal.hour.toString().padLeft(2, '0');
    final minute = expiresAtLocal.minute.toString().padLeft(2, '0');
    return 'Mã hiện tại hết hạn lúc $hour:$minute.';
  }

  static const profileTitle = 'Hồ sơ';
  static const profileGuestTitle = 'Khách của quán';
  static const profileGuestSubtitle = "Thành viên Loaf n' Catting";
  static const logoutButton = 'Đăng xuất';

  static const homeNavLabel = 'Trang chủ';
  static const menuNavLabel = 'Thực đơn';
  static const reservationsNavLabel = 'Đặt bàn';
  static const catsNavLabel = 'Mèo';
  static const profileNavLabel = 'Hồ sơ';
  static const emailLabel = 'Địa chỉ email';
  static const phoneLabel = 'Số điện thoại';

  static const moreTitle = 'Thêm';
  static const moreHeroTitle = 'Góc quán';
  static const moreHeroSubtitle = 'Thông báo, hỗ trợ, hồ sơ và đường đi.';
  static const notificationsTitle = 'Thông báo';
  static const notificationsMenuSubtitle =
      'Cập nhật từ quán và ghi chú đơn hàng';
  static const storeLocationTitle = 'Vị trí cửa hàng';
  static const storeLocationMenuSubtitle = 'Tìm đường đến quán';
  static const chatTitle = 'Trò chuyện';
  static const chatMenuSubtitle = 'Hỏi về giờ mở cửa, đặt bàn và món bán chạy';
  static const profileMenuSubtitle = 'Thông tin tài khoản và đăng xuất';

  static const cartTitlePrefix = 'Giỏ hàng';
  static String cartTitle(int count) => '$cartTitlePrefix ($count)';
  static const cartEmptyMessage = 'Giỏ hàng của bạn đang trống.';
  static const cartHeroTitle = 'Đơn hàng của bạn';
  static const cartHeroSubtitle = 'Kiểm tra món trước khi thanh toán.';
  static const totalLabel = 'Tổng cộng';
  static const checkoutTitle = 'Thanh toán';
  static const checkoutButton = 'Thanh toán';

  static const notificationsEmptyMessage = 'Chưa có thông báo nào.';
  static const chatMessageHint =
      'Hỏi về giờ mở cửa, đặt bàn hoặc món bán chạy...';

  static const storeLocationUnavailableMessage =
      'Chưa có thông tin vị trí cửa hàng.';
  static const storeLocationHeroSubtitle =
      'Đến vì cà phê, ở lại vì những bé mèo.';
  static const openDirectionsButton = 'Mở chỉ đường';

  static const reservationHistoryTitle = 'Lịch sử đặt bàn';
  static const reservationHistoryEmptyMessage = 'Bạn chưa có lượt đặt bàn nào.';
  static String reservationHistoryGuestsSummary(
    String tableName,
    int numberOfGuests,
  ) =>
      '$tableName - $numberOfGuests khách';

  static const checkoutEmptyCartMessage =
      'Giỏ hàng đang trống nên chưa thể thanh toán.';
  static const backToCartButton = 'Quay lại giỏ hàng';
  static const checkoutLoginRequiredMessage =
      'Vui lòng đăng nhập trước khi đặt đơn.';
  static const goToLoginButton = 'Đến trang đăng nhập';
  static const checkoutHeroTitle = 'Sắp xong rồi';
  static const checkoutHeroSubtitle =
      'Xác nhận thông tin trước khi gửi đơn đến quán.';
  static const receiverNameLabel = 'Tên người nhận';
  static const receiverNameFieldName = 'tên người nhận';
  static const phoneNumberLabel = 'Số điện thoại';
  static const orderNoteLabel = 'Ghi chú đơn hàng';
  static const orderNoteHint = 'Thêm ghi chú cho đơn hàng';
  static const paymentMethodLabel = 'Phương thức thanh toán';
  static const cashPaymentMethod = 'Tiền mặt';
  static const creditCardPaymentMethod = 'Thẻ tín dụng';
  static const eWalletPaymentMethod = 'Ví điện tử';
  static const bankTransferPaymentMethod = 'Chuyển khoản ngân hàng';
  static const placeOrderButton = 'Đặt đơn';
  static const orderPlacedSuccessTitle = 'Đặt đơn thành công';
  static const okButton = 'OK';
  static const takeAwayOrderType = 'Mang đi';
  static String orderPlacedSuccessMessage(String receiverName) =>
      'Đơn của $receiverName đã được gửi đến quán.';

  static const reservationTitle = 'Đặt bàn';
  static const reservationHeroTitle = 'Đặt trước một chiếc bàn';
  static const reservationHeroSubtitle =
      'Chọn chỗ ngồi ưng ý trước khi quán đông khách.';
  static const dateLabel = 'Ngày';
  static const timeLabel = 'Giờ';
  static const guestCountLabel = 'Số khách';
  static const loadAvailableTablesButton = 'Tải bàn trống';
  static const tableLabel = 'Bàn';
  static const guestNameLabel = 'Tên khách';
  static const noteLabel = 'Ghi chú';
  static const reservationCreatedMessage = 'Đặt bàn thành công';
  static const reservationFailedMessage = 'Đặt bàn thất bại';
  static const confirmReservationButton = 'Xác nhận đặt bàn';
  static String reservationTableOption(String tableName, int capacity) =>
      '$tableName - $capacity khách';

  static const menuSearchHint = 'Tìm món';
  static const allCategoryLabel = 'Tất cả';
  static const popularPicksTitle = 'Món nổi bật';
  static String menuItemsToday(int count) => '$count món hôm nay';
  static const menuEmptyMessage = 'Không tìm thấy món nào.';
  static const menuGreeting = 'Xin chào, bạn yêu mèo!';
  static const menuWelcomeBack = "Chào mừng bạn quay lại Loaf n' Catting";
  static const addButton = 'Thêm';
  static const inStockLabel = 'Còn hàng';
  static const outOfStockLabel = 'Hết hàng';
  static String productAddedToCart(String productName) =>
      '$productName đã được thêm vào giỏ hàng';
  static String productStockLimitReached(String productName) =>
      '$productName đã đạt giới hạn tồn kho';

  static const productNoDescription = 'Món này chưa có mô tả.';
  static String stockCountLabel(int count) => 'Còn $count';
  static const maxStockReachedMessage =
      'Bạn đã chọn số lượng tối đa còn trong kho.';
  static String addedItemsToCartMessage(int quantity) =>
      'Đã thêm $quantity món vào giỏ hàng';
  static const cartStockLimitReachedMessage =
      'Giỏ hàng đã đạt giới hạn tồn kho cho món này.';
  static const cartSessionExpiredMessage =
      'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
  static const cartSyncFailedMessage =
      'Chưa thể cập nhật giỏ hàng. Vui lòng thử lại.';
  static const addToCartButton = 'Thêm vào giỏ';
  static const perfectWithTitle = 'Hợp với';
  static const similarItemsTitle = 'Món tương tự';
  static const retryButton = 'Thử lại';
  static const unknownBreed = 'Chưa rõ giống';

  static String localizedRoleName(String roleName) {
    switch (roleName.trim().toLowerCase()) {
      case 'admin':
        return 'Quản trị viên';
      case 'staff':
        return 'Nhân viên';
      case 'customer':
        return 'Khách hàng';
      default:
        return roleName;
    }
  }
}
