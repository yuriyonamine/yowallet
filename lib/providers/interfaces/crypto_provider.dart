import '../../models/account.dart';
import '../../models/wallet_summary.dart';

abstract class CryptoProvider {
  void subscribeLiveCoinsUpdate(List<String> userCoinsJSON, Function update);
  Future<WalletSummary> getWalletSummary(List<Account> accounts);
}
