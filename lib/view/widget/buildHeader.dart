import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/model/category.dart';

class BuildHeader extends StatelessWidget {
  // Property
  final Category category;
  final VoidCallback onAddTap;

  const BuildHeader({
    super.key,
    required this.category,
    required this.onAddTap,
  });

  @override
Widget build(BuildContext context) {
  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox( // 높이를 고정하여 안정감 부여
        height: 60,
        child: Row(
          children: [
            // 1. 왼쪽 뒤로가기 버튼 영역 (고정폭)
            SizedBox(
              width: 40,
              child: IconButton(
                alignment: Alignment.centerLeft,
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Get.back(),
              ),
            ),

            // 2. 중앙 카테고리 이름 영역
            Expanded(
              child: Text(
                category.c_name,
                textAlign: TextAlign.center,
                maxLines: 1, // 한 줄로 제한
                overflow: TextOverflow.ellipsis, // 길면 '...' 처리
                style: const TextStyle(
                  fontSize: 24, // 30은 너무 클 수 있으므로 24 정도로 조절 추천
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 3. 오른쪽 추가 버튼 영역 (고정폭 확보)
            IntrinsicWidth( // 텍스트 길이에 맞게 너비 확보
              child: GestureDetector(
                onTap: onAddTap,
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '+ ${AppLocalizations.of(context)!.add}',
                    style: TextStyle(
                      fontSize: 18, // 헤더 밸런스를 위해 살짝 조절
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}