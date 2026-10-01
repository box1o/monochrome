#!/usr/bin/env python3
"""Restore Mono's FreeCAD 1.1 appearance, floating panels, and Fusion shortcuts.

Preview: python3 programs/freecad/freecad.py
Install with FreeCAD closed: python3 programs/freecad/freecad.py --apply
"""

import argparse
import os
import shutil
import tempfile
import xml.etree.ElementTree as ET
from copy import deepcopy
from pathlib import Path

SETTINGS = {
    "BaseApp/Preferences/General": {
        "AutoloadModule": "PartDesignWorkbench",
        "ToolbarIconSize": 18,
    },
    "BaseApp/Preferences/MainWindow": {"Theme": "FreeCAD Dark"},
    "BaseApp/Preferences/View": {
        "NavigationStyle": "Gui::RevitNavigationStyle",
        "EditSketcherFontSize": 11,
    },
    "BaseApp/Preferences/NaviCube": {"CubeSize": 70},
    "BaseApp/Preferences/TreeView": {"FontSize": 9, "ItemBackgroundPadding": 0},
    "BaseApp/Preferences/DockWindows": {"ActivateOverlay": True},
    "BaseApp/Preferences/Mod/Sketcher": {"MakeInternals": False},
    "BaseApp/MainWindow/DockWindows": {
        "Std_ComboView": True,
        "Std_TaskView": True,
        "Std_ReportView": False,
        "Std_PythonView": False,
        "Std_SelectionView": False,
    },
    "BaseApp/MainWindow/DockWindows/OverlayLeft": {
        "Widgets": "Model,",
        "Sizes": "1000",
        "Width": 272,
        "AutoHide": False,
        "EditHide": False,
        "EditShow": False,
        "TaskShow": False,
        "Transparent": True,
    },
    "BaseApp/MainWindow/DockWindows/OverlayRight": {
        "Widgets": "Tasks,",
        "Sizes": "1000",
        "Width": 354,
        "AutoHide": False,
        "EditHide": False,
        "EditShow": False,
        "TaskShow": False,
        "Transparent": True,
    },
}

PROFILE = r'''
"""Fusion-inspired toolbar layout and shortcuts for FreeCAD 1.1."""
import FreeCAD as App
import FreeCADGui as Gui
from PySide import QtCore, QtGui, QtWidgets

SHORTCUTS = {
    'PartDesign_Pad': 'E',
    'PartDesign_Fillet': 'F',
    'PartDesign_Hole': 'H',
    'Std_Measure': 'I',
    'Std_TransformManip': 'M',
    'Std_ToggleVisibility': 'V',
    'Sketcher_CreateLine': 'L',
    'Sketcher_CreateRectangle': 'R',
    'Sketcher_CreateCircle': 'C',
    'Sketcher_ConstrainDistance': 'D',
    'Sketcher_Trimming': 'T',
    'Sketcher_ToggleConstruction': 'X',
    'Sketcher_Offset': 'O',
    'Sketcher_Projection': 'P',
    'Std_SetAppearance': 'A',
    'Std_Refresh': 'Ctrl+B',
    'Std_DlgMacroExecute': 'Shift+S',
    'Std_Redo': 'Ctrl+Y',
    'Std_New': 'Ctrl+N',
    'Std_Open': 'Ctrl+O',
    'Std_Save': 'Ctrl+S',
    'Std_SaveAs': 'Ctrl+Shift+S',
    'Std_Undo': 'Ctrl+Z',
    'Std_Copy': 'Ctrl+C',
    'Std_Paste': 'Ctrl+V',
    'Std_Cut': 'Ctrl+X',
    'Std_Delete': 'Del',
    'Sketcher_LeaveSketch': 'Shift+Esc',
    'Std_ViewFitAll': 'Home',
    'Std_DockOverlayToggleLeft': 'Ctrl+Alt+B',
    'Std_DockOverlayToggleRight': 'Ctrl+Right',
}
_busy = False
_installed = False
_search_shortcut = None


def apply():
    global _busy
    if _busy:
        return
    _busy = True
    try:
        mw = Gui.getMainWindow()
        font = QtWidgets.QApplication.instance().font()
        font.setPointSize(9)
        QtWidgets.QApplication.instance().setFont(font)
        available = set(Gui.listCommands())
        prefs = App.ParamGet('User parameter:BaseApp/Preferences/Shortcut')
        reserved = set(SHORTCUTS.values()) | {'S'}
        # Remove conflicting single keys and chord prefixes before assigning new keys.
        for name in available:
            if name in SHORTCUTS:
                continue
            cmd = Gui.Command.get(name)
            key = cmd.getShortcut()
            if key and key.split(',')[0].strip() in reserved:
                cmd.setShortcut('')
                prefs.SetString(name, '')
        for name, key in SHORTCUTS.items():
            if name in available:
                Gui.Command.get(name).setShortcut(key)
                prefs.SetString(name, key)
        # Restore FreeCAD's complete native toolbar set for the active workbench.
        native = set(Gui.activeWorkbench().listToolbars())
        common = {'File', 'Edit', 'Clipboard', 'Workbench', 'Macro', 'View',
                  'Individual Views', 'Structure', 'Help'}
        for toolbar in mw.findChildren(QtWidgets.QToolBar):
            if toolbar.objectName().startswith('FusionStyle_'):
                toolbar.hide()
            else:
                toolbar.setVisible(toolbar.objectName() in native | common)
                toolbar.setIconSize(QtCore.QSize(18, 18))
        # Native preferences own the overlay layout; only place ordinary docks.
        overlay = App.ParamGet('User parameter:BaseApp/Preferences/DockWindows').GetBool('ActivateOverlay')
        if not overlay:
            for name, side in (('Model', QtCore.Qt.LeftDockWidgetArea),
                               ('Tasks', QtCore.Qt.RightDockWidgetArea)):
                dock = mw.findChild(QtWidgets.QDockWidget, name)
                if dock:
                    mw.addDockWidget(side, dock)
                    dock.show()
                    if name == 'Model':
                        mw.resizeDocks([dock], [220], QtCore.Qt.Horizontal)
        tasks = mw.findChild(QtWidgets.QDockWidget, 'Tasks')
        if tasks:
            tasks.setStyleSheet('QWidget { background-color: transparent; }\nQAbstractItemView, QLineEdit, QComboBox, QAbstractSpinBox, QPushButton { background-color: rgba(30,30,30,155); }\nQHeaderView::section { background-color: rgba(30,30,30,155); }')
        for title in mw.findChildren(QtWidgets.QWidget, 'OverlayTitle'):
            title.setStyleSheet('background-color: #252525; color: #bdbdbd; border: none;')
        App.saveParameter()
    finally:
        _busy = False


def install():
    global _installed, _search_shortcut
    if _installed:
        apply()
        return
    _installed = True
    Gui.addCommand('FusionStyle_CommandSearch', CommandSearch())
    _search_shortcut = QtGui.QShortcut(QtGui.QKeySequence('S'), Gui.getMainWindow())
    _search_shortcut.activated.connect(CommandSearch().Activated)
    Gui.getMainWindow().workbenchActivated.connect(lambda *_: QtCore.QTimer.singleShot(100, apply))
    QtCore.QTimer.singleShot(1500, apply)


class CommandSearch:
    def GetResources(self):
        return {'MenuText': 'Search Tools', 'ToolTip': 'Search modeling and sketch tools (S)', 'Pixmap': 'Std_CommandLine', 'Accel': 'S'}

    def IsActive(self):
        return True

    def Activated(self):
        dialog = QtWidgets.QDialog(Gui.getMainWindow())
        dialog.setWindowTitle('Search Tools')
        dialog.resize(520, 420)
        layout = QtWidgets.QVBoxLayout(dialog)
        field = QtWidgets.QLineEdit(dialog)
        field.setPlaceholderText('Search tools: extrude, fillet, line, circle...')
        results = QtWidgets.QListWidget(dialog)
        layout.addWidget(field)
        layout.addWidget(results)
        aliases = {'PartDesign_Pad': 'Extrude', 'PartDesign_NewSketch': 'Create Sketch'}
        commands = []
        for name in Gui.listCommands():
            if not name.startswith(('PartDesign_', 'Sketcher_', 'Std_Measure', 'Std_View')):
                continue
            cmd = Gui.Command.get(name)
            info = cmd.getInfo()
            label = info.get('menuText', name).replace('&', '')
            if name in aliases:
                label = aliases[name] + ' (' + label + ')'
            commands.append((label, name, cmd))
        def populate(query):
            results.clear()
            for label, name, cmd in sorted(commands):
                if query.lower() not in (label + ' ' + name).lower():
                    continue
                shortcut = cmd.getShortcut()
                item = QtWidgets.QListWidgetItem(label + (f'  [{shortcut}]' if shortcut else ''))
                item.setData(QtCore.Qt.UserRole, name)
                if not cmd.isActive():
                    item.setFlags(item.flags() & ~QtCore.Qt.ItemIsEnabled)
                results.addItem(item)
            if results.count():
                results.setCurrentRow(0)
        selected = []
        def choose(item=None):
            item = item or results.currentItem()
            if item and item.flags() & QtCore.Qt.ItemIsEnabled:
                selected.append(item.data(QtCore.Qt.UserRole))
                dialog.accept()
        field.textChanged.connect(populate)
        field.returnPressed.connect(choose)
        results.itemActivated.connect(choose)
        populate('')
        field.setFocus()
        dialog.exec()
        if selected:
            Gui.runCommand(selected[0])
'''

STARTUP = """import importlib
import sys
from pathlib import Path
import FreeCAD

path = str(Path(FreeCAD.getUserAppDataDir()) / "Mod" / "FusionStyle")
if path not in sys.path:
    sys.path.insert(0, path)
importlib.import_module("fusion_profile").install()
"""


def preferences(path):
    root = ET.parse(path).getroot() if path.exists() else ET.Element("FCParameters")
    if root.tag != "FCParameters":
        raise ValueError("Invalid FreeCAD preferences")
    theme = Path("/usr/share/freecad/Gui/PreferencePacks/FreeCAD Dark/FreeCAD Dark.cfg")
    if not theme.exists():
        raise ValueError(
            "Install FreeCAD 1.1 with its bundled FreeCAD Dark theme first"
        )

    def merge_theme(target, source):
        for item in source:
            match = next(
                (child for child in target if child.get("Name") == item.get("Name")),
                None,
            )
            if item.tag == "FCParamGroup" and match is not None:
                merge_theme(match, item)
            else:
                if match is not None:
                    target.remove(match)
                target.append(deepcopy(item))

    merge_theme(root, ET.parse(theme).getroot())
    for group_path, values in SETTINGS.items():
        group = root
        for name in ("Root/" + group_path).split("/"):
            child = group.find(f"FCParamGroup[@Name='{name}']")
            if child is None:
                child = ET.SubElement(group, "FCParamGroup", Name=name)
            group = child
        for name, value in values.items():
            old = next((item for item in group if item.get("Name") == name), None)
            if old is not None:
                group.remove(old)
            tag = (
                "FCBool"
                if isinstance(value, bool)
                else "FCInt"
                if isinstance(value, int)
                else "FCText"
            )
            child = ET.SubElement(group, tag, Name=name)
            if tag == "FCText":
                child.text = value
            else:
                child.set("Value", str(int(value)))
    ET.indent(root, space="  ")
    return ET.tostring(root, encoding="utf-8", xml_declaration=True) + b"\n"


def running():
    for process in Path("/proc").glob("[0-9]*"):
        try:
            if process.stat().st_uid == os.getuid() and (
                process / "comm"
            ).read_text().strip().lower() in {"freecad", "freecad.main"}:
                return True
        except OSError:
            continue
    return False


def save(path, content):
    path.parent.mkdir(parents=True, exist_ok=True)
    backup = path.with_name(path.name + ".mono-backup")
    if path.exists() and not backup.exists():
        shutil.copy2(path, backup)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(dir=path.parent, delete=False) as stream:
            temporary = Path(stream.name)
            stream.write(content)
        temporary.replace(path)
    finally:
        if temporary and temporary.exists():
            temporary.unlink()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--apply", action="store_true", help="write settings; otherwise preview only"
    )
    args = parser.parse_args()
    if args.apply and running():
        parser.error("Close FreeCAD before applying settings.")
    config = (
        Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
        / "FreeCAD/v1-1/user.cfg"
    )
    data = (
        Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share"))
        / "FreeCAD/v1-1/Mod/FusionStyle"
    )
    try:
        files = {
            config: preferences(config),
            data / "fusion_profile.py": PROFILE.encode(),
            data / "InitGui.py": STARTUP.encode(),
        }
        for path, content in files.items():
            changed = not path.exists() or path.read_bytes() != content
            if args.apply and changed:
                save(path, content)
            action = "Updated" if args.apply else "Would update"
            print(f"{action if changed else 'Unchanged'}: {path}")
    except (OSError, ValueError, ET.ParseError) as error:
        parser.exit(1, f"Configuration failed: {error}\n")


if __name__ == "__main__":
    main()
