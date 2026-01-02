import 'package:bnkproject/api/etf_api.dart';
import 'package:bnkproject/models/EtfTrade.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'stock_detail_page.dart';
import 'package:characters/characters.dart';


class StockBuyPage extends StatefulWidget {
  final String name;
  final int currentPrice;
  final String changePercentText;
  final String stockCode;

  final String pcuid;
  final String pacc;

  const StockBuyPage({
    super.key,
    required this.name,
    required this.currentPrice,
    required this.changePercentText,
    required this.stockCode,
    required this.pcuid,
    required this.pacc
  });

  @override
  State<StockBuyPage> createState() => _StockBuyPageState();
}

class _StockBuyPageState extends State<StockBuyPage> with TickerProviderStateMixin {
  bool _isBuying = false;

  Future<void> _buyEtf({
    required String code,
    required String name,
    required int qty,
    required int price,
  }) async {
    if (_isBuying) return;

    setState(() => _isBuying = true);

    try {
      final total = qty * price;

      final req = EtfBuy(
        pcuid: widget.pcuid,
        pstock: qty,
        pprice: price,
        psum: total,
        pname: widget.name,
        pacc: widget.pacc,
        code: widget.stockCode,
      );

      final result = await api.buyEtf(req);

      // ✅ ApiResult 형태에 맞춘 성공 판정
      if (result.result.toLowerCase() != 'buy') {
        throw Exception('매수 실패(result=${result.result})');
      }

      // ✅ 성공 UI 흐름
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.name} ${qty}주 구매... 주당 ${price.won}에 구매했어요.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2A2B31),
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          duration: const Duration(seconds: 0),
        ),
      );

      _showOrderCompleteSheet(
        context: context,
        name: name,
        qty: qty,
        price: price,
      );
    } catch (e) {
      // ✅ 실패 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('매수 실패: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isBuying = false);
    }
  }

  void _showOrderCompleteSheet({
    required BuildContext context,
    required String name,
    required int qty,
    required int price,
  }) {
    final total = qty * price;

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 260),
    );

    bool disposed = false;
    void safeDispose() {
      if (!disposed) {
        disposed = true;
        controller.dispose();
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      transitionAnimationController: controller,
      builder: (sheetContext) {
        // 시트가 올라온 뒤 1초 후 스르륵 내려가며 닫기
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await Future.delayed(const Duration(seconds: 1));

          // 시트가 이미 닫혔거나, 화면이 사라졌으면 중단
          if (!mounted) return;
          if (!Navigator.of(sheetContext).canPop()) return;

          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          try {
            await controller.reverse(); // ✅ 내려가는 애니메이션
          } catch (_) {
            // 사용자가 드래그로 닫는 중/이미 닫힘 등
          } finally {
            if (Navigator.of(sheetContext).canPop()) {
              Navigator.of(sheetContext).pop(); // ✅ 시트 닫기
            }
          }
        });

        return _OrderCompleteSheet(
          name: name,
          qty: qty,
          price: price,
          total: total,
        );
      },
    ).whenComplete(() {
      // ✅ 사용자가 드래그로 먼저 닫아도 dispose는 여기서 딱 1번
      safeDispose();
    });
  }

  void _showBuyConfirmSheet({
    required BuildContext context,
    required String name,
    required int qty,
    required int price,
  }) {
    final total = qty * price;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (_) {
        return _BuyConfirmSheet(
          name: name,
          qty: qty,
          price: price,
          total: total,
          onClose: () => Navigator.pop(context),
          onConfirm: () async {
            // ✅ 여기(=2번) 넣으면 됨
            Navigator.pop(context); // 1) 확인 시트 닫기

            final qty = _qty;
            final price = _price;

            await _buyEtf(
            code: widget.stockCode,
            name: widget.name,
            qty: qty,
            price: price,
            );

            // 2) 상단 토스트(SnackBar)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$name ${qty}주 구매...  주당 ${price.won}에 구매했어요.'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF2A2B31),
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                duration: const Duration(seconds: 0),
              ),
            );

            // 3) 주문 완료 시트 띄우기
            _showOrderCompleteSheet(
              context: context,
              name: name,
              qty: qty,
              price: price,
            );
          },
        );
      },
    );
  }
  int _selectedPriceTab = 0; // 0: 구매할 가격, 1: 현재가, 2: 시장가
  late int _price; // 구매할 가격
  String _qtyText = ''; // 수량 입력(키패드)

  int get _qty => int.tryParse(_qtyText.isEmpty ? '0' : _qtyText) ?? 0;
  int get _total => _qty * _price;

  late final EtfApiClient api;

  @override
  void initState() {
    super.initState();
    _price = widget.currentPrice; // 초기: 현재가로 세팅
    api = EtfApiClient(baseUrl: 'http://10.0.2.2:8080/BNK');
  }

  @override
  void dispose() {
    super.dispose();
    api.dispose();
  }

  bool get _isUp => !widget.changePercentText.trim().startsWith('-');

  Color get _changeColor => _isUp ? Colors.redAccent : Colors.blue[200]!;

  void _tapKey(String key) {
    setState(() {
      if (key == 'back') {
        if (_qtyText.isNotEmpty) _qtyText = _qtyText.substring(0, _qtyText.length - 1);
        return;
      }

      // "00" / 숫자 입력
      if (_qtyText.length >= 10) return; // 과도 입력 방지
      if (_qtyText == '0' && key != '00') _qtyText = ''; // 0으로 시작 정리
      _qtyText += key;
    });
  }

  void _setPercent(double p) {
    // 예시: "보유 현금" 개념이 없으니, UI만 흉내 (원하면 실제 잔고 넣어서 계산 가능)
    // 여기서는 수량을 "대충" 맞추지 않고, 그냥 표시만 바꾸고 싶으면 이 함수를 커스텀하세요.
    // 일단은 입력값을 비워두지 않게 간단히 1주/2주 같은 형태로 넣어둠.
    setState(() {
      if (p == 1.0) {
        _qtyText = '0'; // "최대"는 계산식이 있어야 해서 자리만
      } else if (p == 0.5) {
        _qtyText = '1';
      } else if (p == 0.25) {
        _qtyText = '1';
      } else {
        _qtyText = '1';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF05060A);
    final card = const Color(0xFF1F2025);

    final displayChange =
    widget.changePercentText.trim().startsWith('-')
        ? widget.changePercentText.trim()
        : '+${widget.changePercentText.trim()}';

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 바 (뒤로가기 + 종목/가격/등락)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Icon(Icons.menu, size: 22),
                ],
              ),
            ),

            // 종목명 + 현재가 + 등락
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.currentPrice.won} $displayChange%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _changeColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // "주문 방법 바꾸기" 흉내
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    '주문 방법 바꾸기',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 구매할 가격 카드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 탭 텍스트
                    Row(
                      children: [
                        _TopTabText(
                          label: '구매할 가격',
                          selected: _selectedPriceTab == 0,
                          onTap: () {
                            setState(() {
                              _selectedPriceTab = 0;
                              // 직접 입력 가격 유지
                            });
                          },
                        ),
                        const SizedBox(width: 12),
                        _TopTabText(
                          label: '현재가',
                          selected: _selectedPriceTab == 1,
                          onTap: () {
                            setState(() {
                              _selectedPriceTab = 1;
                              _price = widget.currentPrice;
                            });
                          },
                        ),
                        const SizedBox(width: 12),
                        _TopTabText(
                          label: '시장가',
                          selected: _selectedPriceTab == 2,
                          onTap: () {
                            setState(() {
                              _selectedPriceTab = 2;
                              _price = widget.currentPrice; // 시장가도 표시만 동일 처리
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _price.won,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 수량 카드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      '수량',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _qtyText.isEmpty ? '몇 주 구매할까요?' : _qtyText,
                        style: TextStyle(
                          fontSize: 18,
                          color: _qtyText.isEmpty ? Colors.white30 : Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.check, color: Colors.white54, size: 18),
                    const SizedBox(width: 2),
                    const Text('미수거래', style: TextStyle(color: Colors.white54)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 퍼센트 버튼들
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _PercentChip(label: '10%', onTap: () => _setPercent(0.10)),
                  const SizedBox(width: 10),
                  _PercentChip(label: '25%', onTap: () => _setPercent(0.25)),
                  const SizedBox(width: 10),
                  _PercentChip(label: '50%', onTap: () => _setPercent(0.50)),
                  const SizedBox(width: 10),
                  _PercentChip(label: '최대', onTap: () => _setPercent(1.0)),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // 키패드
            Expanded(
              child: _NumberPad(
                onKey: _tapKey,
              ),
            ),

            // 하단 버튼들 (호가 / 구매하기)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2A2B31),
                            foregroundColor: Colors.white70,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            // TODO: 호가 보기 연결(원하면 기존 호가 탭으로 이동)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('호가 버튼(연결 예정)')),
                            );
                          },
                          child: const Text('호가', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 5,
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _isBuying
                            ? null
                            : () {
                                final qty = _qty;

                                if (qty <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('수량을 입력해 주세요.')),
                                  );
                                  return;
                                }

                                _showBuyConfirmSheet(
                                  context: context,
                                  name: widget.name,
                                  qty: qty,
                                  price: _price,
                                );
                              },
                          child: _isBuying
                            ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('구매하기', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopTabText extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TopTabText({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          color: selected ? Colors.white : Colors.white38,
        ),
      ),
    );
  }
}

class _PercentChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PercentChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white12),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  final void Function(String key) onKey;

  const _NumberPad({required this.onKey});

  @override
  Widget build(BuildContext context) {
    Widget key(String text, {VoidCallback? onTap}) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: text == 'back'
                ? const Icon(Icons.backspace_outlined, color: Colors.white70)
                : Text(
              text,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              key('1', onTap: () => onKey('1')),
              key('2', onTap: () => onKey('2')),
              key('3', onTap: () => onKey('3')),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              key('4', onTap: () => onKey('4')),
              key('5', onTap: () => onKey('5')),
              key('6', onTap: () => onKey('6')),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              key('7', onTap: () => onKey('7')),
              key('8', onTap: () => onKey('8')),
              key('9', onTap: () => onKey('9')),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              key('00', onTap: () => onKey('00')),
              key('0', onTap: () => onKey('0')),
              key('back', onTap: () => onKey('back')),
            ],
          ),
        ),
      ],
    );
  }
}


class _BuyConfirmSheet extends StatelessWidget {
  final String name;
  final int qty;
  final int price;
  final int total;
  final VoidCallback onClose;
  final VoidCallback onConfirm;

  const _BuyConfirmSheet({
    required this.name,
    required this.qty,
    required this.price,
    required this.total,
    required this.onClose,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final card = const Color(0xFF1F2025);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 핸들
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 18),

              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
                  children: [
                    TextSpan(text: '${qty}주 '),
                    const TextSpan(
                      text: '구매',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              _RowItem(left: '1주 희망 가격', right: price.won),
              const SizedBox(height: 14),

              // 수수료(예시 0원)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Expanded(
                    child: Text(
                      '예상 수수료',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
                  Text(
                    '0원',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '국내 주식 수수료 무료',
                  style: TextStyle(color: Colors.white38),
                ),
              ),

              const SizedBox(height: 18),
              _RowItem(left: '총 주문 금액', right: total.won),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A2B31),
                          foregroundColor: Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: onClose,
                        child: const Text('닫기', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: onConfirm,
                        child: const Text('구매', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final String left;
  final String right;

  const _RowItem({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ),
        Text(
          right,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _OrderCompleteSheet extends StatelessWidget {
  final String name;
  final int qty;
  final int price;
  final int total;

  const _OrderCompleteSheet({
    required this.name,
    required this.qty,
    required this.price,
    required this.total,
  });

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';

    // 공백 기준 첫 단어
    final firstWord = trimmed.split(RegExp(r'\s+')).first;

    // 한글이면 앞 2글자, 아니면 앞 3글자(길면 3)
    final isHangul = RegExp(r'^[가-힣]').hasMatch(firstWord);

    if (isHangul) {
      return firstWord.characters.take(2).toString();
    } else {
      final upper = firstWord.toUpperCase();
      return upper.characters.take(3).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = const Color(0xFF1F2025);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(26),
          ),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 18),

              // 로고 원 + 체크 뱃지(스크린샷 느낌)
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _initials(name),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                '$name 주문 완료',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 22),

              _RowItem(left: '1주 희망 가격', right: price.won),
              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Expanded(
                    child: Text(
                      '예상 수수료',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
                  Text(
                    '0원',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '국내 주식 수수료 무료',
                  style: TextStyle(color: Colors.white38),
                ),
              ),

              const SizedBox(height: 18),
              _RowItem(left: '총 주문 금액', right: total.won),
            ],
          ),
        ),
      ),
    );
  }
}
