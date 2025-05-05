#include <err.h>
#include <errno.h>
#include <poll.h>
#include <sys/mman.h>
#include <sys/timerfd.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
  int timer = timerfd_create(CLOCK_MONOTONIC, 0);

  if (timer < 0) err(1, "timerfd");

  ssize_t page_sz = sysconf(_SC_PAGE_SIZE), n;
  char   *page    = mmap(0, page_sz, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANON, -1, 0);

  if (page == MAP_FAILED) err(1, "mmap");

  while (n = read(0, page, page_sz), n > 0) {
    struct itimerspec t = { .it_value.tv_sec = 10 };
    if (timerfd_settime(timer, 0, &t, 0) < 0) err(1, "settime");

    struct pollfd fds[] = {
      { .fd = timer, .events = POLLIN },
      { .fd = 0,     .events = POLLIN },
    };
    if (poll(fds, 2, -1) < 0) err(1, "poll");

    if (fds[0].revents&POLLIN || fds[1].revents&POLLHUP) write(1, page, n);
  }

  if (errno) err(1, "read");
}
