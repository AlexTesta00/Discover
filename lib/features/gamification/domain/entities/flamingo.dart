class Flamingo {
  int _amount;

  int get amount => _amount;

  set amount(int value) {
    _amount = value;
  }

  Flamingo({int amount = 0}) : _amount = amount;

  void addFlamingo(int flamingo){
    assert(flamingo > 0);
    _amount += flamingo;
  }

  void removeFlamingo(int flamingo){
    assert(flamingo > 0);
    assert((_amount - flamingo) > 0);
    _amount -= flamingo;
  }
}