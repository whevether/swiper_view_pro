// Shared virtual page range used by the looping page controller.
const int kMaxValue = 2000000000;
const int kMiddleValue = 1000000000;

int normalizeSwiperIndex(int index, int itemCount, bool loop) {
  if (itemCount <= 0) return 0;
  return loop ? index % itemCount : index.clamp(0, itemCount - 1);
}

int swiperRealIndex(int index, int itemCount, bool loop, bool reverse) {
  if (itemCount <= 0) return 0;
  final normalized = normalizeSwiperIndex(index, itemCount, loop);
  return (reverse ? itemCount - normalized - 1 : normalized) +
      (loop ? kMiddleValue : 0);
}
