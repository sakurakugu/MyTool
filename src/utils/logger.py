import logging
import os
import sys
from logging.handlers import RotatingFileHandler
from pathlib import Path
from datetime import datetime
from PySide6.QtCore import QtMsgType, qInstallMessageHandler

_logger_initialized = False


def _resolve_log_dir(app_name):
    if os.name == "nt":
        base = os.getenv("LOCALAPPDATA") or str(Path.home() / "AppData" / "Local")
        return Path(base) / app_name / "logs"
    xdg_state = os.getenv("XDG_STATE_HOME")
    if xdg_state:
        return Path(xdg_state) / app_name / "logs"
    return Path.home() / ".local" / "state" / app_name / "logs"


class _ConsoleFormatter(logging.Formatter):
    def formatTime(self, record, datefmt=None):
        return datetime.fromtimestamp(record.created).astimezone().strftime("%H:%M:%S.%f")


class _FileFormatter(logging.Formatter):
    def formatTime(self, record, datefmt=None):
        return datetime.fromtimestamp(record.created).astimezone().isoformat(timespec="milliseconds")


def _parse_level(level_value, debug):
    if level_value:
        value = str(level_value).upper()
        return logging._nameToLevel.get(value, logging.INFO)
    return logging.DEBUG if debug else logging.INFO


def init_logging(app_name, log_level=None, debug=False):
    global _logger_initialized
    if _logger_initialized:
        return get_logger()
    level = _parse_level(log_level, debug)
    if debug:
        log_dir = Path(__file__).resolve().parents[2] / "logs"
    else:
        log_dir = _resolve_log_dir(app_name)
    log_dir.mkdir(parents=True, exist_ok=True)
    log_file = log_dir / f"{app_name}.log"
    console_formatter = _ConsoleFormatter("[%(asctime)s] [%(levelname)s] [%(name)s] %(message)s")
    file_formatter = _FileFormatter("[%(asctime)s] [%(levelname)s] [%(name)s] %(message)s")
    logger = logging.getLogger("mytool")
    logger.setLevel(logging.DEBUG)
    logger.handlers.clear()
    logger.propagate = False
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(level)
    console_handler.setFormatter(console_formatter)
    file_handler = RotatingFileHandler(log_file, maxBytes=10 * 1024 * 1024, backupCount=5, encoding="utf-8")
    file_handler.setLevel(level)
    file_handler.setFormatter(file_formatter)
    logger.addHandler(console_handler)
    logger.addHandler(file_handler)
    _logger_initialized = True
    return logger


def get_logger(name=None):
    logger = logging.getLogger("mytool")
    if name:
        return logger.getChild(name)
    return logger


def _qt_level(mode):
    if mode == QtMsgType.QtDebugMsg:
        return logging.DEBUG
    if mode == QtMsgType.QtInfoMsg:
        return logging.INFO
    if mode == QtMsgType.QtWarningMsg:
        return logging.WARNING
    if mode == QtMsgType.QtCriticalMsg:
        return logging.ERROR
    if mode == QtMsgType.QtFatalMsg:
        return logging.CRITICAL
    return logging.INFO


def _qt_message_handler(mode, context, message):
    logger = get_logger("qt")
    level = _qt_level(mode)
    try:
        file_name = getattr(context, "file", None)
        line = getattr(context, "line", None)
        function = getattr(context, "function", None)
        if file_name or line or function:
            location = f"{file_name}:{line} {function}".strip()
            logger.log(level, f"{location} {message}")
        else:
            logger.log(level, message)
    except Exception:
        logger.log(level, message)


def install_qt_message_handler():
    qInstallMessageHandler(_qt_message_handler)
