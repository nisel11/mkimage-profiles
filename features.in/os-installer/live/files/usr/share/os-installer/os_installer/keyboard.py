# SPDX-License-Identifier: GPL-3.0-or-later

from gi.repository import Gio, Gtk

from .config import config
from .keyboard_layout_provider import get_default_layout, get_layouts_for
from .language_provider import language_provider
from .system_calls import set_system_keyboard_layout
from .widgets import reset_model, ProgressRow


@Gtk.Template(resource_path='/com/github/p3732/os-installer/ui/pages/keyboard_language.ui')
class KeyboardLanguagePage(Gtk.Box):
    __gtype_name__ = __qualname__

    list = Gtk.Template.Child()
    model = Gtk.Template.Child()

    def __init__(self, **kwargs):
        Gtk.Box.__init__(self, **kwargs)

        self.model.splice(0, 0, language_provider.get_all_languages())
        self.list.bind_model(self.model, lambda o: ProgressRow(o.name, o))

    ### callbacks ###

    @Gtk.Template.Callback('language_row_activated')
    def _language_row_activated(self, list_box, row):
        info = row.info
        config.set('keyboard_language', (info.language_code, info.name))
        config.set_next_page(self)


@Gtk.Template(resource_path='/com/github/p3732/os-installer/ui/pages/keyboard_layout.ui')
class KeyboardLayoutPage(Gtk.Box):
    __gtype_name__ = __qualname__

    language_row = Gtk.Template.Child()
    layout_list = Gtk.Template.Child()
    model = Gtk.Template.Child()

    def __init__(self, **kwargs):
        Gtk.Box.__init__(self, **kwargs)

        self.layout_list.bind_model(
            self.model, lambda o: ProgressRow(o.name, o))

        config.subscribe('keyboard_language', self._update_keyboard_language)

    ### callbacks ###

    def _update_keyboard_language(self, language):
        code, name = language
        reset_model(self.model, get_layouts_for(code, name))
        self.language_row.set_subtitle(name)

    @Gtk.Template.Callback('layout_row_activated')
    def _layout_row_activated(self, list_box, row):
        # use selected keyboard layout
        set_system_keyboard_layout(keyboard_info=row.info)
        config.set_next_page(self)

    @Gtk.Template.Callback('show_language_selection')
    def _show_language_selection(self, row):
        config.set('displayed-page', 'keyboard-language')


@Gtk.Template(resource_path='/com/github/p3732/os-installer/ui/pages/keyboard_overview.ui')
class KeyboardOverviewPage(Gtk.Box):
    __gtype_name__ = __qualname__

    primary_layout_row = Gtk.Template.Child()

    def __init__(self, **kwargs):
        Gtk.Box.__init__(self, **kwargs)

        if not config.has('keyboard_layout'):
            language_code, language = config.get('language')
            config.set('keyboard_language', (language_code, language))
            keyboard = get_default_layout(language_code)
            set_system_keyboard_layout(keyboard_info=keyboard)

        config.subscribe('keyboard_layout', self._update_primary_layout)

    ### callbacks ###

    def _update_primary_layout(self, keyboard_layout):
        _, name = keyboard_layout
        self.primary_layout_row.set_title(name)

    @Gtk.Template.Callback('continue')
    def _continue(self, button):
        config.set_next_page(self)

    @Gtk.Template.Callback('show_layout_selection')
    def _show_layout_selection(self, row):
        config.set('displayed-page', 'keyboard-layout')
