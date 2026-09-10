// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
// import 'package:softai/extensions/l10n_extension.dart';

// class PaywallScreen extends StatefulWidget {
//   const PaywallScreen({super.key});

//   @override
//   State<PaywallScreen> createState() => _PaywallScreenState();
// }

// class _PaywallScreenState extends State<PaywallScreen> {
//   Offering? _offering;
//   bool _isLoading = true;
//   bool _isPurchasing = false;
//   Package? _selectedPackage;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _loadOffering();
//   }

//   Future<void> _loadOffering() async {
//     try {
//       final offerings = await Purchases.getOfferings();
//       final current = offerings.current;

//       if (current != null) {
//         setState(() {
//           _offering = current;
//           _isLoading = false;
//           // Default to annual if available (better value)
//           _selectedPackage = current.annual ?? current.monthly;
//         });
//       } else {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = 'No subscription plans available';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'Failed to load: $e';
//       });
//     }
//   }

//   Future<void> _purchase() async {
//     if (_selectedPackage == null || _isPurchasing) return;

//     setState(() => _isPurchasing = true);

//     try {
//       final purchaseResult = await Purchases.purchasePackage(_selectedPackage!);
//       final isPro =
//           purchaseResult.customerInfo.entitlements.active.containsKey('pro');
//       if (!mounted) return;

//       if (isPro) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(context.isEnglish
//                 ? 'Welcome to Skillena Pro! 🎉'
//                 : 'Dobrodošao u Skillena Pro! 🎉'),
//             backgroundColor: const Color(0xFF00CC88),
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//         Navigator.of(context).pop(true);
//       }
//     } on PlatformException catch (e) {
//       final errorCode = PurchasesErrorHelper.getErrorCode(e);
//       if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Purchase failed: ${e.message}'),
//               backgroundColor: Colors.red.shade700,
//               behavior: SnackBarBehavior.floating,
//             ),
//           );
//         }
//       }
//     } finally {
//       if (mounted) setState(() => _isPurchasing = false);
//     }
//   }

//   Future<void> _restore() async {
//     setState(() => _isPurchasing = true);
//     try {
//       final customerInfo = await Purchases.restorePurchases();
//       final isPro = customerInfo.entitlements.active.containsKey('pro');

//       if (!mounted) return;

//       if (isPro) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(context.isEnglish
//                 ? 'Purchases restored!'
//                 : 'Kupovine vraćene!'),
//             backgroundColor: const Color(0xFF00CC88),
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//         Navigator.of(context).pop(true);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(context.isEnglish
//                 ? 'No previous purchases found'
//                 : 'Nema prethodnih kupovina'),
//             backgroundColor: Colors.orange.shade700,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Restore failed: $e'),
//             backgroundColor: Colors.red.shade700,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isPurchasing = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final l10n = context.l10n;

//     return Scaffold(
//       backgroundColor: const Color(0xFF006FFF),
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(false),
//         ),
//         actions: [
//           TextButton(
//             onPressed: _restore,
//             child: Text(
//               context.isEnglish ? 'Restore' : 'Vrati',
//               style: const TextStyle(
//                 fontFamily: 'Montserrat',
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           Container(
//             width: double.infinity,
//             height: double.infinity,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Color(0xFF006FFF),
//                   Color(0xFF00AAF2),
//                   Color(0xFF00E5E5),
//                   Color(0xFF0BFF96),
//                 ],
//                 stops: [0.0, 0.24, 0.49, 1.0],
//               ),
//             ),
//           ),
//           SafeArea(
//             child: _isLoading
//                 ? const Center(
//                     child: CircularProgressIndicator(color: Colors.white),
//                   )
//                 : _errorMessage != null
//                     ? Center(
//                         child: Padding(
//                           padding: const EdgeInsets.all(24),
//                           child: Text(
//                             _errorMessage!,
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontFamily: 'Montserrat',
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                       )
//                     : _buildContent(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContent() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
//       child: Column(
//         children: [
//           Image.asset('assets/avatar.png', width: 100, height: 100),
//           const SizedBox(height: 20),
//           const Text(
//             'Skillena Pro',
//             style: TextStyle(
//               fontFamily: 'Montserrat',
//               fontSize: 32,
//               fontWeight: FontWeight.w800,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             context.isEnglish
//                 ? 'Unlock everything Skillena offers'
//                 : 'Otključaj sve što Skillena nudi',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontFamily: 'Montserrat',
//               fontSize: 16,
//               color: Colors.white.withValues(alpha: 0.9),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 32),

//           // Features
//           _buildFeature(
//               '💬',
//               context.isEnglish
//                   ? 'Unlimited AI conversations'
//                   : 'Neograničeni AI razgovori'),
//           _buildFeature(
//               '🎯',
//               context.isEnglish
//                   ? 'Unlimited personal goals'
//                   : 'Neograničeni lični ciljevi'),
//           _buildFeature(
//               '🎓',
//               context.isEnglish
//                   ? 'Advanced practice scenarios'
//                   : 'Napredni scenariji vežbanja'),
//           _buildFeature('🎤',
//               context.isEnglish ? 'Voice conversations' : 'Glasovni razgovori'),
//           _buildFeature(
//               '📊',
//               context.isEnglish
//                   ? 'Detailed progress tracking'
//                   : 'Detaljno praćenje napretka'),

//           const SizedBox(height: 32),

//           // Plans
//           if (_offering!.annual != null)
//             _buildPlanCard(
//               package: _offering!.annual!,
//               title: context.isEnglish ? 'Yearly' : 'Godišnje',
//               savingsBadge: context.isEnglish ? 'Save 40%' : 'Uštedi 40%',
//               perPeriodLabel: context.isEnglish ? 'per year' : 'godišnje',
//             ),
//           const SizedBox(height: 12),
//           if (_offering!.monthly != null)
//             _buildPlanCard(
//               package: _offering!.monthly!,
//               title: context.isEnglish ? 'Monthly' : 'Mesečno',
//               perPeriodLabel: context.isEnglish ? 'per month' : 'mesečno',
//             ),

//           const SizedBox(height: 24),

//           // Purchase button
//           SizedBox(
//             width: double.infinity,
//             height: 52,
//             child: ElevatedButton(
//               onPressed: _isPurchasing ? null : _purchase,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white,
//                 foregroundColor: const Color(0xFF0055CC),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(26),
//                 ),
//                 elevation: 0,
//               ),
//               child: _isPurchasing
//                   ? const SizedBox(
//                       width: 24,
//                       height: 24,
//                       child: CircularProgressIndicator(
//                         color: Color(0xFF0055CC),
//                         strokeWidth: 2,
//                       ),
//                     )
//                   : Text(
//                       context.isEnglish ? 'Continue' : 'Nastavi',
//                       style: const TextStyle(
//                         fontFamily: 'Montserrat',
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             context.isEnglish
//                 ? 'Cancel anytime. Auto-renews unless canceled.'
//                 : 'Otkaži bilo kada. Automatski se obnavlja.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontFamily: 'Montserrat',
//               fontSize: 11,
//               color: Colors.white.withValues(alpha: 0.7),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFeature(String icon, String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Row(
//         children: [
//           Text(icon, style: const TextStyle(fontSize: 20)),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               text,
//               style: const TextStyle(
//                 fontFamily: 'Montserrat',
//                 fontSize: 15,
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPlanCard({
//     required Package package,
//     required String title,
//     String? savingsBadge,
//     required String perPeriodLabel,
//   }) {
//     final isSelected = _selectedPackage?.identifier == package.identifier;
//     final priceString = package.storeProduct.priceString;

//     return GestureDetector(
//       onTap: () => setState(() => _selectedPackage = package),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color:
//               isSelected ? Colors.white : Colors.white.withValues(alpha: 0.15),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color:
//                 isSelected ? Colors.white : Colors.white.withValues(alpha: 0.4),
//             width: 2,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 22,
//               height: 22,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color:
//                     isSelected ? const Color(0xFF0055CC) : Colors.transparent,
//                 border: Border.all(
//                   color: isSelected ? const Color(0xFF0055CC) : Colors.white,
//                   width: 2,
//                 ),
//               ),
//               child: isSelected
//                   ? const Icon(Icons.check, size: 14, color: Colors.white)
//                   : null,
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         title,
//                         style: TextStyle(
//                           fontFamily: 'Montserrat',
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                           color: isSelected
//                               ? const Color(0xFF1A1A2E)
//                               : Colors.white,
//                         ),
//                       ),
//                       if (savingsBadge != null) ...[
//                         const SizedBox(width: 8),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF00CC88),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Text(
//                             savingsBadge,
//                             style: const TextStyle(
//                               fontFamily: 'Montserrat',
//                               fontSize: 11,
//                               fontWeight: FontWeight.w700,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     '$priceString $perPeriodLabel',
//                     style: TextStyle(
//                       fontFamily: 'Montserrat',
//                       fontSize: 13,
//                       color: isSelected
//                           ? const Color(0xFF1A1A2E).withValues(alpha: 0.7)
//                           : Colors.white.withValues(alpha: 0.8),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:softai/extensions/l10n_extension.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  Offering? _offering;
  bool _isLoading = true;
  bool _isPurchasing = false;
  Package? _selectedPackage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOffering();
  }

  Future<void> _loadOffering() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      if (current != null) {
        setState(() {
          _offering = current;
          _isLoading = false;
          _selectedPackage = current.annual ?? current.monthly;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No plans available';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load: $e';
      });
    }
  }

  Future<void> _purchase() async {
    if (_selectedPackage == null || _isPurchasing) return;

    setState(() => _isPurchasing = true);

    try {
      final purchaseResult = await Purchases.purchasePackage(_selectedPackage!);
      final isPro =
          purchaseResult.customerInfo.entitlements.active.containsKey('pro');

      if (!mounted) return;

      if (isPro) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.isEnglish
                ? 'Welcome to Skillena Pro! 🎉'
                : 'Dobrodošao u Skillena Pro! 🎉'),
            backgroundColor: const Color(0xFF00CC88),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Purchase failed: ${e.message}'),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _isPurchasing = true);
    try {
      final customerInfo = await Purchases.restorePurchases();
      final isPro = customerInfo.entitlements.active.containsKey('pro');

      if (!mounted) return;

      if (isPro) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.isEnglish
                ? 'Purchases restored!'
                : 'Kupovine vraćene!'),
            backgroundColor: const Color(0xFF00CC88),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.isEnglish
                ? 'No previous purchases found'
                : 'Nema prethodnih kupovina'),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF006FFF),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        actions: [
          TextButton(
            onPressed: _restore,
            child: Text(
              context.isEnglish ? 'Restore' : 'Vrati',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF006FFF),
                  Color(0xFF00AAF2),
                  Color(0xFF00E5E5),
                  Color(0xFF0BFF96),
                ],
                stops: [0.0, 0.24, 0.49, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final isEng = context.isEnglish;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Skillena',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 84, 204, 204),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'AI',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Avatar with Pro badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset('assets/avatar.png'),
                  ),
                ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 12),
                      SizedBox(width: 3),
                      Text(
                        'PRO',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            isEng ? 'Unlock everything' : 'Otključaj sve',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isEng
                ? 'Get the full Skillena experience and grow every soft skill you need.'
                : 'Iskoristi Skillenu u punom kapacitetu i razvij sve meke veštine.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Features card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeatureRow('🧠',
                    isEng ? 'All 20 soft skills' : 'Svih 20 mekih veština'),
                _buildFeatureRow('💬',
                    isEng ? 'Unlimited AI messages' : 'Neograničene AI poruke'),
                _buildFeatureRow(
                    '🎯', isEng ? 'Unlimited goals' : 'Neograničeni ciljevi'),
                _buildFeatureRow('🎓',
                    isEng ? 'Practice scenarios' : 'Scenariji za vežbanje'),
                _buildFeatureRow(
                    '🎤', isEng ? 'Voice conversations' : 'Glasovni razgovori'),
                _buildFeatureRow(
                    '🏆',
                    isEng
                        ? 'Skill quiz certification'
                        : 'Sertifikacija kroz kviz'),
                _buildFeatureRow(
                    '⚡',
                    isEng
                        ? 'Priority to new features'
                        : 'Prioritet za nove opcije',
                    isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Plans
          if (_offering != null) ...[
            if (_offering!.annual != null)
              _buildPlanCard(
                package: _offering!.annual!,
                title: isEng ? 'Yearly' : 'Godišnje',
                subtitle: isEng ? 'Best value' : 'Najbolja ponuda',
                badge: isEng ? '33% OFF' : 'UŠTEDI 33%',
                perPeriodLabel: isEng ? '/year' : '/god.',
                originalPrice: _calculateOriginalYearly(),
              ),
            const SizedBox(height: 10),
            if (_offering!.monthly != null)
              _buildPlanCard(
                package: _offering!.monthly!,
                title: isEng ? 'Monthly' : 'Mesečno',
                perPeriodLabel: isEng ? '/month' : '/mes.',
              ),
          ],
          const SizedBox(height: 20),

          // Purchase button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isPurchasing ? null : _purchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0055CC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27),
                ),
                elevation: 0,
              ),
              child: _isPurchasing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Color(0xFF0055CC),
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isEng ? 'Continue' : 'Nastavi',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isEng
                ? 'Cancel anytime. Auto-renews unless canceled.'
                : 'Otkaži bilo kada. Automatski se obnavlja.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              color: const Color.fromARGB(255, 114, 113, 113)
                  .withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String icon, String text, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0066FF).withValues(alpha: 0.1),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _calculateOriginalYearly() {
    if (_offering?.monthly == null) return null;
    final monthlyPrice = _offering!.monthly!.storeProduct.price;
    final yearlyEquivalent = monthlyPrice * 12;
    final currency = _offering!.monthly!.storeProduct.currencyCode;
    return _formatCurrency(yearlyEquivalent, currency);
  }

  String _formatCurrency(double amount, String currencyCode) {
    // Simple format — RevenueCat's priceString handles locale but we need custom for original
    if (currencyCode == 'USD') return '\$${amount.toStringAsFixed(2)}';
    if (currencyCode == 'EUR') return '€${amount.toStringAsFixed(2)}';
    if (currencyCode == 'RSD') return '${amount.toStringAsFixed(0)} RSD';
    return '${amount.toStringAsFixed(2)} $currencyCode';
  }

  Widget _buildPlanCard({
    required Package package,
    required String title,
    String? subtitle,
    String? badge,
    String? originalPrice,
    required String perPeriodLabel,
  }) {
    final isSelected = _selectedPackage?.identifier == package.identifier;
    final priceString = package.storeProduct.priceString;

    return GestureDetector(
      onTap: () => setState(() => _selectedPackage = package),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? Colors.white : Colors.white.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Radio
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? const Color(0xFF0055CC) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFF0055CC) : Colors.white,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? const Color(0xFF1A1A2E)
                              : Colors.white,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFD700),
                                Color(0xFFFFA500),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF00CC88)
                            : Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        priceString,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? const Color(0xFF1A1A2E)
                              : Colors.white,
                        ),
                      ),
                      Text(
                        ' $perPeriodLabel',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF1A1A2E).withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      if (originalPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          originalPrice,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.grey.shade400
                                : Colors.white.withValues(alpha: 0.5),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
