import 'package:flowpay/features/auth/domain/entities/app_user.dart';
import 'package:flutter/material.dart';
import '../../../../helpers/ui_responsive_helper.dart';
import '../../data/services/favourite_services.dart';

class FavPlusMoneyBtn extends StatefulWidget {
  final Widget buttoncontent;
  final VoidCallback onTap;
  final AppUser? receiver;

  const FavPlusMoneyBtn({
    super.key,
    required this.buttoncontent,
    required this.onTap,
    this.receiver,
  });

  @override
  State<FavPlusMoneyBtn> createState() => _FavPlusMoneyBtnState();
}

class _FavPlusMoneyBtnState extends State<FavPlusMoneyBtn>
    with SingleTickerProviderStateMixin {
  bool _isFav = false;
  bool _loading = false;

  late AnimationController _starCtrl;
  late Animation<double> _starScale;

  @override
  void initState() {
    super.initState();
    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 1.0,
    );
    _starScale = CurvedAnimation(parent: _starCtrl, curve: Curves.elasticOut);
    _checkFav();
  }

  @override
  void didUpdateWidget(FavPlusMoneyBtn old) {
    super.didUpdateWidget(old);
    if (old.receiver?.uid != widget.receiver?.uid) _checkFav();
  }

  @override
  void dispose() {
    _starCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkFav() async {
    if (widget.receiver == null) {
      setState(() => _isFav = false);
      return;
    }
    final fav = await FavouritesService.isFavourite(widget.receiver!.uid);
    if (mounted) setState(() => _isFav = fav);
  }

  Future<void> _toggle() async {
    if (widget.receiver == null || _loading) return;
    setState(() => _loading = true);
    _starCtrl.value = 0.6;
    _starCtrl.forward();
    try {
      final nowFav = await FavouritesService.toggleFavourite(widget.receiver!);
      if (mounted) {
        setState(() {
          _isFav = nowFav;
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              nowFav
                  ? '${widget.receiver!.name} added to favourites ⭐'
                  : '${widget.receiver!.name} removed from favourites',
            ),
            backgroundColor:
                nowFav ? const Color(0xff007AFF) : const Color(0xff737373),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppResponsive.radiusSm),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final h = AppResponsive.h(54).clamp(46.0, 62.0);

    return Row(
      children: [
        // ── Star (flex 1) ──────────────────────────────────────────────
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: _toggle,
            child: ScaleTransition(
              scale: _starScale,
              child: Container(
                height: h,
                decoration: BoxDecoration(
                  color:
                      _isFav
                          ? const Color(0xffFFF3CD)
                          : const Color(0xffF5F5F5),
                  borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
                  border: Border.all(
                    color:
                        _isFav
                            ? const Color(0xffFFBB00)
                            : const Color(0xffE5E5E5),
                  ),
                ),
                child:
                    _loading
                        ? Center(
                          child: SizedBox(
                            height: AppResponsive.sp(16),
                            width: AppResponsive.sp(16),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xffFFBB00),
                            ),
                          ),
                        )
                        : Icon(
                          _isFav
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color:
                              _isFav
                                  ? const Color(0xffFFBB00)
                                  : const Color(0xff737373),
                          size: AppResponsive.sp(24),
                        ),
              ),
            ),
          ),
        ),

        SizedBox(width: AppResponsive.w(8)),

        // ── Send (flex 5) ──────────────────────────────────────────────
        Expanded(
          flex: 5,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              height: h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
                color: const Color(0xff007AFF),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: widget.buttoncontent),
                  Padding(
                    padding: EdgeInsets.only(right: AppResponsive.w(16)),
                    child: Image.asset(
                      'assets/transfer/send.png',
                      height: AppResponsive.sp(20),
                      width: AppResponsive.sp(20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
