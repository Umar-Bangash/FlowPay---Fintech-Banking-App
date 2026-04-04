class BillCategoryIcon {
  static String getIcon(String category) {
    switch (category) {
      case 'Electricity':
        return 'assets/bill/electricity.png';

      case 'Gas':
        return 'assets/bill/gas.png';

      case 'Water':
        return 'assets/bill/water.png';

      case 'Internet':
        return 'assets/bill/internet.png';

      case 'Education':
        return 'assets/bill/education.png';

      case 'Telephone':
        return 'assets/bill/telephone.png';

      case 'Insurance':
        return 'assets/bill/insurance.png';

      case 'Government':
        return 'assets/bill/government.png';

      default:
        return 'assets/bill/more.png';
    }
  }
}
