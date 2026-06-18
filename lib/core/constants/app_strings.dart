class AppStrings {
  const AppStrings._();

  static const appTitle = "Loaf'NCatting";
  static const loginIdentityLabel = 'Email or phone';
  static const loginIdentityHint = 'Enter email or phone';
  static const passwordLabel = 'Password';
  static const passwordHint = 'Enter password';
  static const forgotPassword = 'Forgot password?';
  static const signInButton = 'Sign in';
  static const registerButton = 'Register';
  static const createAccountButton = 'Create account';
  static const createAccountTitle = 'Create account';
  static const profileTitle = 'Profile';
  static const logoutButton = 'Logout';

  static const homeNavLabel = 'Home';
  static const menuNavLabel = 'Menu';
  static const reservationsNavLabel = 'Reservations';
  static const catsNavLabel = 'Cats';
  static const profileNavLabel = 'Profile';

  static const moreTitle = 'More';
  static const moreHeroTitle = 'Cafe corner';
  static const moreHeroSubtitle =
      'Notifications, support, profile, and directions.';
  static const notificationsTitle = 'Notifications';
  static const notificationsMenuSubtitle = 'Cafe updates and order notes';
  static const storeLocationTitle = 'Store Location';
  static const storeLocationMenuSubtitle = 'Find your way to the cafe';
  static const chatTitle = 'Chat';
  static const chatMenuSubtitle =
      'Ask about hours, reservations, and best sellers';
  static const profileMenuSubtitle = 'Account details and logout';

  static const cartTitlePrefix = 'Cart';
  static String cartTitle(int count) => '$cartTitlePrefix ($count)';
  static const cartEmptyMessage = 'Your cart is empty.';
  static const cartHeroTitle = 'Your order';
  static const cartHeroSubtitle = 'Review your items before checkout.';
  static const totalLabel = 'Total';
  static const checkoutTitle = 'Checkout';
  static const checkoutButton = 'Checkout';

  static const notificationsEmptyMessage = 'No notifications yet.';
  static const chatMessageHint =
      'Ask about hours, reservations, or best sellers...';

  static const storeLocationUnavailableMessage =
      'Store location is not available.';
  static const storeLocationHeroSubtitle =
      'Come for the coffee, stay for the paws.';
  static const openDirectionsButton = 'Open directions';

  static const reservationHistoryTitle = 'Reservation History';
  static const reservationHistoryEmptyMessage = 'No reservations yet.';
  static String reservationHistoryGuestsSummary(
    String tableName,
    int numberOfGuests,
  ) =>
      '$tableName - $numberOfGuests guests';

  static const checkoutEmptyCartMessage =
      'Your cart is empty, so checkout is unavailable.';
  static const backToCartButton = 'Back to cart';
  static const checkoutLoginRequiredMessage =
      'Please sign in before placing an order.';
  static const goToLoginButton = 'Go to sign in';
  static const checkoutHeroTitle = 'Almost there';
  static const checkoutHeroSubtitle =
      'Confirm your details before sending the order to the cafe.';
  static const receiverNameLabel = 'Receiver name';
  static const receiverNameFieldName = 'receiver name';
  static const phoneNumberLabel = 'Phone number';
  static const orderNoteLabel = 'Order note';
  static const orderNoteHint = 'Add a note for your order';
  static const paymentMethodLabel = 'Payment method';
  static const cashPaymentMethod = 'Cash';
  static const creditCardPaymentMethod = 'Credit card';
  static const eWalletPaymentMethod = 'E-wallet';
  static const bankTransferPaymentMethod = 'Bank transfer';
  static const placeOrderButton = 'Place order';
  static const orderPlacedSuccessTitle = 'Order placed';
  static const okButton = 'OK';
  static const takeAwayOrderType = 'Takeaway';
  static String orderPlacedSuccessMessage(String receiverName) =>
      "$receiverName's order has been sent to the cafe.";

  static const reservationTitle = 'Reservation';
  static const reservationHeroTitle = 'Reserve a table';
  static const reservationHeroSubtitle =
      'Choose a cozy spot before the cafe fills up.';
  static const dateLabel = 'Date';
  static const timeLabel = 'Time';
  static const guestCountLabel = 'Guest count';
  static const loadAvailableTablesButton = 'Load available tables';
  static const tableLabel = 'Table';
  static const guestNameLabel = 'Guest name';
  static const noteLabel = 'Note';
  static const reservationCreatedMessage = 'Reservation created';
  static const reservationFailedMessage = 'Reservation failed';
  static const confirmReservationButton = 'Confirm Reservation';
  static String reservationTableOption(String tableName, int capacity) =>
      '$tableName - $capacity guests';

  static const menuSearchHint = 'Search menu';
  static const allCategoryLabel = 'All';
  static const popularPicksTitle = 'Popular Picks';
  static String menuItemsToday(int count) =>
      '$count item${count == 1 ? '' : 's'} today';
  static const menuEmptyMessage = 'No menu items found.';
  static const menuGreeting = 'Hello, Cat Lover!';
  static const menuWelcomeBack = "Welcome back to Loaf n' Catting";
  static const addButton = 'Add';
  static const inStockLabel = 'In stock';
  static const outOfStockLabel = 'Out of stock';
  static String productAddedToCart(String productName) =>
      '$productName added to cart';
  static String productStockLimitReached(String productName) =>
      '$productName has reached the stock limit';

  static const productNoDescription = 'No description available yet.';
  static String stockCountLabel(int count) => '$count left';
  static const maxStockReachedMessage =
      'You have selected the maximum quantity in stock.';
  static String addedItemsToCartMessage(int quantity) =>
      '$quantity item${quantity == 1 ? '' : 's'} added to cart';
  static const cartStockLimitReachedMessage =
      'Your cart has reached the stock limit for this item.';
  static const addToCartButton = 'Add to cart';
}
