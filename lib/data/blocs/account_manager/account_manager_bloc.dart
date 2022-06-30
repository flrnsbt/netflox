import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:netflox/data/models/exception.dart';
import 'package:netflox/data/models/user.dart';

part 'account_manager_event.dart';
part 'account_manager_state.dart';

class AccountManager extends Bloc<AccountManagerEvent, AccountManagerState> {
  AccountManager() : super(AccountStateLoading()) {
    on<AccountManagerEvent>((event, emit) {});
  }
}
