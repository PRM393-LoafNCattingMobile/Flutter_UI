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
  static const profileAvatarSectionTitle = 'Ảnh đại diện';
  static const profileAvatarSectionSubtitle =
      'Tải ảnh JPG/PNG tối đa 1 MB để cập nhật hồ sơ.';
  static const profileAvatarUploadButton = 'Cập nhật ảnh đại diện';
  static const profileAvatarUpdatedMessage = 'Đã cập nhật ảnh đại diện.';
  static const profileEditButton = 'Chỉnh sửa hồ sơ';
  static const profileEditTitle = 'Chỉnh sửa hồ sơ';
  static const editProfileButton = 'Chỉnh sửa hồ sơ';
  static const editProfileTitle = 'Chỉnh sửa hồ sơ';
  static const profileUpdatedMessage = 'Đã cập nhật hồ sơ.';
  static const profileUpdateFailedMessage = 'Không thể cập nhật hồ sơ.';
  static const profileNameLabel = 'Họ tên';
  static const profilePhoneLabel = 'Số điện thoại';
  static const saveButton = 'Lưu';
  static const cancelButton = 'Hủy';
  static const nameRequiredMessage = 'Vui lòng nhập tên.';
  static const phoneRequiredMessage = 'Vui lòng nhập số điện thoại.';
  static const logoutButton = 'Đăng xuất';

  static const homeNavLabel = 'Trang chủ';
  static const menuNavLabel = 'Thực đơn';
  static const reservationsNavLabel = 'Đặt bàn';
  static const catsNavLabel = 'Mèo';
  static const profileNavLabel = 'Hồ sơ';
  static const nameLabel = 'Tên';
  static const emailLabel = 'Địa chỉ email';
  static const phoneLabel = 'Số điện thoại';

  static const moreTitle = 'Thêm';
  static const moreHeroTitle = 'Góc quán';
  static const moreHeroSubtitle = 'Thông báo, hỗ trợ, hồ sơ và đường đi.';
  static const notificationsTitle = 'Thông báo';
  static const notificationsMenuSubtitle =
      'Cập nhật từ quán và ghi chú đơn hàng';
  static const orderHistoryTitle = 'Lịch sử đơn hàng';
  static const orderHistoryMenuSubtitle =
      'Xem trạng thái và món trong các đơn đã đặt';
  static const orderHistoryEmptyMessage = 'Bạn chưa có đơn hàng nào.';
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
  static const closeButton = 'Đóng';
  static const continuePaymentButton = 'Thanh toán tiếp';
  static const reviewAgainButton = 'Kiểm tra lại';
  static const pendingPaymentTitle = 'Bạn còn đơn chờ thanh toán';
  static String orderPaidMessage(int orderId) =>
      'Đơn #$orderId đã được thanh toán.';
  static const payOsTitle = 'Thanh toán PayOS';
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
  static const futureReservationTimeRequiredMessage =
      'Vui lòng chọn khung giờ đặt bàn trong tương lai.';
  static const timeSlotFullLabel = 'Hết khung giờ';

  static const menuSearchHint = 'Tìm món';
  static const allCategoryLabel = 'Tất cả';
  static const popularPicksTitle = 'Món nổi bật';
  static String menuItemsToday(int count) => '$count món hôm nay';
  static const menuEmptyMessage = 'Không tìm thấy món nào.';
  static String menuGreeting(String username) => 'Xin chào $username';
  static const menuWelcomeBack = "Chào mừng bạn quay lại Loaf n' Catting";
  static const addButton = 'Thêm';
  static const inStockLabel = 'Còn hàng';
  static const outOfStockLabel = 'Hết hàng';
  static String productAddedToCart(String productName) =>
      '$productName đã được thêm vào giỏ hàng';
  static const resetButton = 'Reset';
  static const filterSheetTitle = 'Bộ lọc';
  static const availabilityFilterTitle = 'Tình trạng';
  static const priceFilterTitle = 'Giá';
  static const sortFilterTitle = 'Sắp xếp';
  static const discountedOnlyLabel = 'Chỉ món giảm giá';
  static const applyButton = 'Áp dụng';
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

  // Admin/Staff shell (Task 8 - mobile admin foundation).
  static const adminDashboardNavLabel = 'Tổng quan';
  static const adminOrdersNavLabel = 'Đơn hàng';
  static const adminReservationsNavLabel = 'Đặt bàn';
  static const adminCatalogNavLabel = 'Thực đơn';
  static const adminCatsNavLabel = 'Mèo';
  static const adminChatNavLabel = 'Chat';
  static const adminMoreNavLabel = 'Thêm';

  static const adminDashboardTitle = 'Tổng quan';
  static const adminOrdersTitle = 'Quản lý đơn hàng';
  static const adminReservationsTitle = 'Quản lý đặt bàn';
  static const adminCatalogTitle = 'Quản lý thực đơn';
  static const adminCatsTitle = 'Quản lý mèo';
  static const adminMoreTitle = 'Khác';

  static const adminComingSoonMessage = 'Tính năng đang được hoàn thiện.';

  // Admin/Staff - Orders & Reservations (Task 10).
  static const adminOrdersEmptyMessage = 'Chưa có đơn hàng nào.';
  static const adminReservationsEmptyMessage = 'Chưa có lượt đặt bàn nào.';
  static const adminFilterAllStatuses = 'Tất cả trạng thái';
  static const adminFilterByStatusLabel = 'Lọc theo trạng thái';
  static const adminUpdateStatusButton = 'Cập nhật trạng thái';
  static const adminUpdateStatusTitle = 'Chọn trạng thái mới';
  static const adminStatusUpdatedMessage = 'Đã cập nhật trạng thái.';
  static const adminPaymentStatusPrefix = 'Thanh toán: ';
  static const adminNoNextStatusMessage =
      'Đơn này chưa có thao tác trạng thái phù hợp.';
  static const adminOrderDetailFallbackError = 'Không tải được chi tiết đơn.';
  static const adminCookingDetailButton = 'Chi tiết nấu';
  static const adminItemsToPrepareTitle = 'Món cần chuẩn bị';
  static const adminOrderHasNoItemsMessage = 'Đơn này chưa có dòng món.';
  static const adminReservationFinalStatusMessage =
      'Lượt đặt bàn này đã ở trạng thái cuối.';
  static String adminOrderCodeLabel(int id) => 'Đơn #$id';
  static String adminOrderCustomerLabel(String name) => 'Khách: $name';
  static String adminReservationGuestLabel(String name, String phone) =>
      '$name - $phone';

  // Admin/Staff - Catalog, Cats, Tables (Task 11).
  static const adminCatalogEmptyMessage = 'Chưa có sản phẩm nào.';
  static const adminCatsEmptyMessage = 'Chưa có bé mèo nào.';
  static const adminTablesEmptyMessage = 'Chưa có bàn nào.';
  static const adminManageCategoriesTitle = 'Quản lý danh mục';
  static const adminCategoriesEmptyMessage = 'Chưa có danh mục nào.';
  static const adminTablesTitle = 'Quản lý bàn';

  static const adminAddProductTitle = 'Thêm sản phẩm';
  static const adminEditProductTitle = 'Sửa sản phẩm';
  static const adminAddCategoryTitle = 'Thêm danh mục';
  static const adminEditCategoryTitle = 'Sửa danh mục';
  static const adminAddCatTitle = 'Thêm mèo';
  static const adminEditCatTitle = 'Sửa hồ sơ mèo';
  static const adminAddTableTitle = 'Thêm bàn';
  static const adminEditTableTitle = 'Sửa bàn';

  static const adminUpdateStockTitle = 'Cập nhật tồn kho';
  static const adminSaveButton = 'Lưu';
  static const adminDeleteButton = 'Xóa';
  static const adminDeleteConfirmTitle = 'Xác nhận xóa';
  static const adminDeleteConfirmMessage = 'Bạn có chắc muốn xóa mục này?';
  static const adminCancelButton = 'Hủy';
  static const adminSavedMessage = 'Đã lưu.';
  static const adminDeletedMessage = 'Đã xóa.';

  static const productNameLabel = 'Tên sản phẩm';
  static const productDescriptionLabel = 'Mô tả';
  static const productPriceLabel = 'Giá';
  static const productDiscountPriceLabel = 'Giá khuyến mãi';
  static const productStockLabel = 'Tồn kho';
  static const productPictureLabel = 'Ảnh (S3 key)';
  static const productCategoryLabel = 'Danh mục';
  static const productAvailableLabel = 'Đang bán';

  static const categoryNameLabel = 'Tên danh mục';
  static const categoryDescriptionLabel = 'Mô tả';

  static const catNameLabel = 'Tên mèo';
  static const catAgeLabel = 'Tuổi';
  static const catGenderLabel = 'Giới tính';
  static const catBreedLabel = 'Giống';
  static const catPictureLabel = 'Ảnh (S3 key)';
  static const catDescriptionLabel = 'Mô tả';
  static const catFriendlinessLabel = 'Thân thiện (1-5)';
  static const catCutenessLabel = 'Đáng yêu (1-5)';
  static const catPlayfulnessLabel = 'Tinh nghịch (1-5)';
  static const catStatusLabel = 'Trạng thái';

  static const tableNameLabel = 'Tên bàn';
  static const tableCapacityLabel = 'Sức chứa';
  static const tableAreaLabel = 'Khu vực';
  static const tableDescriptionLabel = 'Mô tả';
  static const tableStatusLabel = 'Trạng thái';

  static const adminFieldRequiredMessage = 'Không được để trống';
  static const adminInvalidNumberMessage = 'Giá trị không hợp lệ';
  static const imageUploadHint = 'Chỉ hỗ trợ JPG/PNG, tối đa 1 MB.';
  static const imageUploadButton = 'Tải ảnh lên';
  static const imageReplaceButton = 'Đổi ảnh';
  static const imageRemoveButton = 'Xóa ảnh';
  static const imageUploadSuccessMessage = 'Đã tải ảnh lên S3.';
  static const imageUploadFailedMessage = 'Tải ảnh thất bại.';

  // Admin/Staff - Dashboard, Users, Store, More (Task 12).
  static const adminDashboardPendingOrders = 'Đơn chờ xử lý';
  static const adminDashboardTodayReservations = 'Đặt bàn hôm nay';
  static const adminDashboardLowStock = 'Sản phẩm sắp hết';
  static const adminDashboardCatsNotWorking = 'Mèo nghỉ/ốm';
  static const adminLowStockOnlyLabel = 'Sản phẩm sắp hết';
  static const adminCatsNotWorkingOnlyLabel = 'Mèo nghỉ/ốm';
  static const adminTableMapTitle = 'Sơ đồ bàn';
  static const adminSendButton = 'Gửi';

  static const adminUsersTitle = 'Quản lý người dùng';
  static const adminUsersEmptyMessage = 'Chưa có người dùng nào.';
  static const adminUsersSearchHint = 'Tìm theo tên/email/SĐT';
  static const adminCreateStaffTitle = 'Tạo nhân viên';
  static const adminChangeRoleTitle = 'Đổi vai trò';
  static const adminUserActiveLabel = 'Đang hoạt động';
  static const adminUserInactiveLabel = 'Đã khóa';
  static const adminActivateAction = 'Kích hoạt';
  static const adminDeactivateAction = 'Khóa';
  static const adminChangeRoleAction = 'Đổi vai trò';

  static const adminStoreLocationTitle = 'Vị trí cửa hàng';
  static const adminStoreNameLabel = 'Tên cửa hàng';
  static const adminStoreAddressLabel = 'Địa chỉ';
  static const adminStorePhoneLabel = 'Số điện thoại';
  static const adminStoreHoursLabel = 'Giờ mở cửa';
  static const adminStoreLatitudeLabel = 'Vĩ độ (latitude)';
  static const adminStoreLongitudeLabel = 'Kinh độ (longitude)';

  static const adminMoreManageTables = 'Quản lý bàn';
  static const adminMoreManageUsers = 'Quản lý người dùng';
  static const adminMoreStoreLocation = 'Cập nhật vị trí cửa hàng';
  static const adminMoreChat = 'Trò chuyện với khách';
  static const adminChatComingSoon = 'Tính năng chat sẽ sớm có mặt.';
  static const adminChatTitle = 'Hộp thư khách hàng';
  static const adminChatEmptyMessage = 'Chưa có cuộc trò chuyện nào.';
  static const adminChatSubtitle =
      'Theo dõi tin nhắn mới và phản hồi khách hàng theo thời gian thực.';
  static const adminChatThreadSubtitle =
      'Trao đổi hỗ trợ trực tiếp với khách hàng.';
  static const adminChatComposerHint = 'Nhập phản hồi cho khách hàng';
  static const adminChatCustomerLabel = 'Khách hàng';
  static const adminChatStoreLabel = 'Hỗ trợ';

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
