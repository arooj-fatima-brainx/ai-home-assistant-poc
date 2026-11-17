import asyncio
import logging

log = logging.getLogger("simulator")


async def run() -> None:
    log.info("simulator started")
    while True:
        await asyncio.sleep(3600)


def main() -> None:
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s %(message)s")
    asyncio.run(run())


if __name__ == "__main__":
    main()
