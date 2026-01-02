import 'package:bnkproject/api/etf_api.dart';
import 'package:bnkproject/models/EtfTrade.dart';
import 'package:flutter/material.dart';
import 'package:characters/characters.dart';
import 'stock_detail_page.dart'; // won extension 쓰려고

/*
  날짜 : 2026.01.02.
  이름 : 강민철
  내용 : 매도 api 연결
 */

class StockSellPage extends StatefulWidget {
  final String name;
  final int currentPrice;
  final String changePercentText;
  final String stockCode;
  final String pcuid;
  final String pacc;

  const StockSellPage({
    super.key,
    required this.name,
    required this.currentPrice,
    required this.changePercentText,
    required this.stockCode,
    required this.pcuid,
    required this.pacc,
  });

  @override
  State<StockSellPage> createState() => _StockSellPageState();
}

class _StockSellPageState extends State<StockSellPage> with TickerProviderStateMixin {
  late final EtfApiClient api;
  bool _isSelling = false;

  int _selectedPriceTab = 0; // 0: 판매할 가격, 1: 현재가, 2: 시장가
  late int _price;
  String _qtyText = '';

  int get _qty => int.tryParse(_qtyText.isEmpty ? '0' : _qtyText) ?? 0;
  int get _total => _qty * _price;

  bool get _isUp => !widget.changePercentText.trim().startsWith('-');
  Color get _changeColor => _isUp ? Colors.redAccent : Colors.blue[200]!;

  @override
  void initState() {
    super.initState();
    api = EtfApiClient(baseUrl: 'http://10.0.2.2:8080/BNK');
    _price = widget.currentPrice;
  }

  @override
  void dispose() {
    api.dispose();
    super.dispose();
  }

  Future<void> _sellEtf({
    required int qty,
    required int price,
  }) async {
    if (_isSelling) return;

    setState(() => _isSelling = true);

    try {
      final total = qty * price;

      final req = EtfSell(
        psum: total,              // ✅ 모델상 매도는 총액만 보냄
        pacc: widget.pacc,
        pname: widget.name,
        pcuid: widget.pcuid,
        code: widget.stockCode,
      );

      final result = await api.sellEtf(req);

      // ✅ ApiResult.result가 "sell" 이면 성공이라는 가정
      if (result.result.toLowerCase() != 'sell') {
        throw Exception('매도 실패(result=${result.result})');
      }

      // ✅ 성공 UI (토스트 + 완료시트)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.name} ${qty}주 판매...  주당 ${price.won}에 판매했어요.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2A2B31),
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          duration: const Duration(seconds: 1),
        ),
      );

      _showOrderCompleteSheet(
        context: context,
        name: widget.name,
        qty: qty,
        price: price,
        isSell: true,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('매도 실패: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSelling = false);
    }
  }


  void _tapKey(String key) {
    setState(() {
      if (key == 'back') {
        if (_qtyText.isNotEmpty) _qtyText = _qtyText.substring(0, _qtyText.length - 1);
        return;
      }
      if (_qtyText.length >= 10) return;
      if (_qtyText == '0' && key != '00') _qtyText = '';
      _qtyText += key;
    });
  }

  void _setPercent(double p) {
    setState(() {
      // TODO: 보유 수량 기반 계산으로 바꾸고 싶으면 여기 수정
      _qtyText = '1';
    });
  }

  // ✅ 판매 확인 시트
  void _showSellConfirmSheet({
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
      builder: (sheetContext) {
        return _SellConfirmSheet(
          name: name,
          qty: qty,
          price: price,
          total: total,
          onClose: () => Navigator.pop(context),
          onConfirm: () async {
            Navigator.pop(sheetContext); // 1) 확인 시트 닫기
            await _sellEtf(qty: qty, price: price);

            // 2) 토스트(판매)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$name ${qty}주 판매...  주당 ${price.won}에 판매했어요.'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF2A2B31),
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                duration: const Duration(seconds: 1),
              ),
            );

            // 3) 주문 완료 시트(판매) 띄우기
            _showOrderCompleteSheet(
              context: context,
              name: name,
              qty: qty,
              price: price,
              isSell: true,
            );
          },
        );
      },
    );
  }

  // ✅ 주문 완료 시트 (1초 후 스르륵 내려가기)
  void _showOrderCompleteSheet({
    required BuildContext context,
    required String name,
    required int qty,
    required int price,
    required bool isSell,
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
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await Future.delayed(const Duration(seconds: 1));
          if (!mounted) return;
          if (!Navigator.of(sheetContext).canPop()) return;

          // ✅ 남아있는 토스트가 있으면 먼저 숨김(검은 박스 방지)
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          try {
            await controller.reverse();
          } catch (_) {
          } finally {
            if (Navigator.of(sheetContext).canPop()) {
              Navigator.of(sheetContext).pop();
            }
          }
        });

        return _OrderCompleteSheet(
          name: name,
          qty: qty,
          price: price,
          total: total,
          isSell: isSell,
        );
      },
    ).whenComplete(() {
      safeDispose();
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
            // 상단 바
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
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text('주문 방법 바꾸기', style: TextStyle(color: Colors.white70)),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 판매할 가격 카드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18)),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _TopTabText(
                          label: '판매할 가격',
                          selected: _selectedPriceTab == 0,
                          onTap: () => setState(() => _selectedPriceTab = 0),
                        ),
                        const SizedBox(width: 12),
                        _TopTabText(
                          label: '현재가',
                          selected: _selectedPriceTab == 1,
                          onTap: () => setState(() {
                            _selectedPriceTab = 1;
                            _price = widget.currentPrice;
                          }),
                        ),
                        const SizedBox(width: 12),
                        _TopTabText(
                          label: '시장가',
                          selected: _selectedPriceTab == 2,
                          onTap: () => setState(() {
                            _selectedPriceTab = 2;
                            _price = widget.currentPrice;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _price.won,
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 수량 카드(오른쪽에 총액 표시)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18)),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text('수량', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _qtyText.isEmpty ? '몇 주 판매할까요?' : '${_qtyText}주',
                        style: TextStyle(
                          fontSize: 18,
                          color: _qtyText.isEmpty ? Colors.white30 : Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      _qtyText.isEmpty ? '' : '총 ${_total.won}',
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 퍼센트
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
            Expanded(child: _NumberPad(onKey: _tapKey)),

            // 하단 버튼(호가 / 판매하기)
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
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
                            backgroundColor: const Color(0xFF3B82F6), // ✅ 파란색
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _isSelling
                            ? null
                            : () {
                                final qty = _qty;
                                if (qty <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('수량을 입력해 주세요.')),
                                  );
                                  return;
                                }
                                _showSellConfirmSheet(
                                  context: context,
                                  name: widget.name,
                                  qty: qty,
                                  price: _price,
                                );
                              },
                          child: const Text('판매하기', style: TextStyle(fontSize: 18)),
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

// ---------- 공용 위젯들(StockBuyPage랑 동일) ----------
class _TopTabText extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TopTabText({required this.label, required this.selected, required this.onTap});

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
            style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.w700),
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
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(child: Row(children: [key('1', onTap: () => onKey('1')), key('2', onTap: () => onKey('2')), key('3', onTap: () => onKey('3'))])),
        Expanded(child: Row(children: [key('4', onTap: () => onKey('4')), key('5', onTap: () => onKey('5')), key('6', onTap: () => onKey('6'))])),
        Expanded(child: Row(children: [key('7', onTap: () => onKey('7')), key('8', onTap: () => onKey('8')), key('9', onTap: () => onKey('9'))])),
        Expanded(child: Row(children: [key('00', onTap: () => onKey('00')), key('0', onTap: () => onKey('0')), key('back', onTap: () => onKey('back'))])),
      ],
    );
  }
}

// ---------- 판매 확인 시트 ----------
class _SellConfirmSheet extends StatelessWidget {
  final String name;
  final int qty;
  final int price;
  final int total;
  final VoidCallback onClose;
  final VoidCallback onConfirm;

  const _SellConfirmSheet({
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
          decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(22)),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(99))),
              const SizedBox(height: 18),
              Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
                  children: [
                    TextSpan(text: '${qty}주 '),
                    const TextSpan(text: '판매', style: TextStyle(color: Color(0xFF3B82F6))),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _RowItem(left: '1주 희망 가격', right: price.won),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Expanded(child: Text('예상 수수료', style: TextStyle(fontSize: 16, color: Colors.white70))),
                  Text('0원', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerRight,
                child: Text('국내 주식 수수료 무료', style: TextStyle(color: Colors.white38)),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: onConfirm,
                        child: const Text('판매', style: TextStyle(fontSize: 18)),
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

// ---------- 주문 완료 시트(구매/판매 공용) ----------
class _OrderCompleteSheet extends StatelessWidget {
  final String name;
  final int qty;
  final int price;
  final int total;
  final bool isSell;

  const _OrderCompleteSheet({
    required this.name,
    required this.qty,
    required this.price,
    required this.total,
    required this.isSell,
  });

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final firstWord = trimmed.split(RegExp(r'\s+')).first;
    final isHangul = RegExp(r'^[가-힣]').hasMatch(firstWord);
    if (isHangul) return firstWord.characters.take(2).toString();
    return firstWord.toUpperCase().characters.take(3).toString();
  }

  @override
  Widget build(BuildContext context) {
    final card = const Color(0xFF1F2025);
    final actionText = isSell ? '판매' : '구매';
    final actionColor = isSell ? const Color(0xFF3B82F6) : Colors.redAccent;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(26)),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(99))),
              const SizedBox(height: 18),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(
                      _initials(name),
                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 20),
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('$name 주문 완료', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(
                '${qty}주 $actionText 완료',
                style: TextStyle(color: actionColor, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),
              _RowItem(left: '1주 희망 가격', right: price.won),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Expanded(child: Text('예상 수수료', style: TextStyle(fontSize: 16, color: Colors.white70))),
                  Text('0원', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerRight,
                child: Text('국내 주식 수수료 무료', style: TextStyle(color: Colors.white38)),
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

class _RowItem extends StatelessWidget {
  final String left;
  final String right;
  const _RowItem({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(left, style: const TextStyle(fontSize: 16, color: Colors.white70))),
        Text(right, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
