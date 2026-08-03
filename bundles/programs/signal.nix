{ bundleLib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "signal" ] {

  nixos =
    { pkgs, config, ... }:
    let
      css =
        with config.lib.stylix.colors;
        pkgs.writeText "signal-stylix.css"
          # css
          ''
            /* ======== NavTabs (leftmost bar) ======== */
            .NavTabs {
              background-color: #${base01} !important;
            }
            .NavTabs__ItemButton:hover {
              background-color: #${base02} !important;
            }
            .NavTabs__Item[aria-selected="true"] > span > .NavTabs__ItemButton {
              background-color: #${base03} !important;
            }

            /* buttons in QR/link section of profile */
            .UsernameLinkModalBody__actions__save,
            .UsernameLinkModalBody__actions__color {
              background-color: #${base03} !important;
            }

            /* ======== NavSidebar ======== */
            .NavSidebar {
              background-color: #${base01} !important;
            }

            /* context menu */
            .ContextMenu__popper--single-item {
              background-color: #${base02} !important;
            }
            .module-conversation-list__item--contact-or-conversation--is-selected {
              background-color: #${base03} !important;
            }
            .module-left-pane__archive-helper-text {
              background-color: #${base02} !important;
            }
            .module-conversation-list__item--contact-or-conversation:hover,
            .module-conversation-list__item--contact-or-conversation:focus,
            .module-conversation-list__item--archive-button:hover,
            .module-conversation-list__item--archive-button:focus {
              background-color: #${base02} !important;
            }

            /* ======== Inbox/conversation area ======== */
            .Inbox__no-conversation-open {
              background-color: #${base00} !important;
            }

            /* ======== Conversation Header ======== */
            .module-ConversationHeader {
              background-color: #${base00} !important;
            }
            .module-ConversationHeader__button:hover,
            .module-ConversationHeader__button:focus {
              background-color: #${base02} !important;
            }
            .react-contextmenu {
              background-color: #${base02} !important;
            }
            .react-contextmenu-item--selected {
              background-color: #${base03} !important;
            }

            /* voice message player */
            .MiniPlayer {
              background-color: #${base03} !important;
            }

            /* timeline / message area */
            .module-timeline {
              background-color: #${base00} !important;
            }

            /* incoming messages */
            .module-message__container--incoming {
              background-color: #${base02} !important;
            }

            /* reply box */
            .module-quote--incoming > .module-quote__primary,
            .module-quote--incoming > .module-quote__icon-container {
              background-color: #${base03} !important;
              border: 0px !important;
            }

            /* call again button */
            .module-Button--system-message {
              background-color: #${base03} !important;
            }

            /* composition area */
            .CompositionArea {
              background-color: #${base00} !important;
            }
            .module-composition-input__input {
              background-color: #${base02} !important;
            }

            /* date header & scroll */
            .TimelineDateHeader--floating {
              background-color: #${base02} !important;
            }
            .TimelineFloatingHeader__spinner-container {
              background-color: #${base02} !important;
            }
            .ScrollDownButton {
              background-color: #${base02} !important;
            }

            /* ======== Calls tab ======== */
            .CallsTab__EmptyState,
            .CallsTab__ConversationCallDetails {
              background-color: #${base00} !important;
            }
            .CallsList__ItemTile:hover {
              background-color: #${base02} !important;
            }
            .CallsList__ItemTile[aria-selected="true"] {
              background-color: #${base03} !important;
            }
            .CallsNewCall_ItemActionButton {
              background-color: #${base04} !important;
            }

            /* ======== Stories ======== */
            .Stories__placeholder {
              background-color: #${base00} !important;
            }

            /* ======== Conversation panel (user details) ======== */
            .ConversationPanel,
            .ConversationPanel__header {
              background-color: #${base00} !important;
            }
            .module-select > select {
              background-color: #${base02} !important;
            }
            .ConversationDetails-panel-row__root--button:hover {
              background-color: #${base02} !important;
            }

            /* nickname edit */
            .Input__container {
              background-color: #${base02} !important;
              border-color: #${base04} !important;
            }

            /* add to group button */
            .ConversationDetails-groups__add-to-group-icon {
              background-color: #${base02} !important;
            }

            /* modals */
            .module-Modal {
              background-color: #${base00} !important;
            }
            .module-SafetyNumberViewer__button > button {
              background-color: #${base03} !important;
            }

            /* ======== Lightbox ======== */
            .Lightbox__animated {
              background-color: #${base00} !important;
            }

            /* general buttons */
            .module-Button {
              background-color: #${base03} !important;
            }
            .module-Button:hover {
              background-color: #${base02} !important;
            }

            /* ======== Preferences/settings ======== */
            .Preferences__page-selector {
              background-color: #${base00} !important;
            }
            .Preferences__settings-pane {
              background-color: #${base00} !important;
            }
            .Preferences__button--selected {
              background-color: #${base03} !important;
            }
            .Preferences__button:focus {
              background-color: #${base02} !important;
            }
            .Preferences__control--clickable:hover {
              background-color: #${base02} !important;
            }
            .module-Button--secondary--destructive {
              color: #${base08} !important;
            }

            /* ======== Calling ======== */
            .module-calling__container {
              background-color: #${base00} !important;
            }
            .CallSettingsButton__Button {
              background-color: #${base02} !important;
            }
            .CallControls {
              background-color: #${base02} !important;
            }
            .CallingButton__icon {
              background-color: #${base04} !important;
            }
            .module-calling__background {
              background-color: #${base02} !important;
            }
          '';
    in
    {
      environment.systemPackages = [
        (pkgs.signal-desktop.overrideAttrs (oldAttrs: {
          patches = oldAttrs.patches ++ [
            (pkgs.writeText "more-fps.patch" ''
              diff --git a/ts/calling/constants.std.ts b/ts/calling/constants.std.ts
              index df863d7a3..29d84b964 100644
              --- a/ts/calling/constants.std.ts
              +++ b/ts/calling/constants.std.ts
              @@ -14,7 +14,7 @@ export const REQUESTED_GROUP_VIDEO_HEIGHT = 480;
               export const REQUESTED_SCREEN_SHARE_WIDTH = 2880;
               export const REQUESTED_SCREEN_SHARE_HEIGHT = 1800;
               // 15fps is much nicer but takes up a lot more CPU.
              -export const REQUESTED_SCREEN_SHARE_FRAMERATE = 5;
              +export const REQUESTED_SCREEN_SHARE_FRAMERATE = 20;
               
               export const MAX_FRAME_WIDTH = 2880;
               export const MAX_FRAME_HEIGHT = 1800;
            '')
          ];

          preBuild = (oldAttrs.preBuild or "") + ''
            cp ${css} stylesheets/stylix.css
            LINE=$(grep -n '^@use\|^@forward' stylesheets/manifest.scss | tail -1 | cut -d: -f1)
            sed -i "''${LINE}a @import \"stylix.css\";" stylesheets/manifest.scss
          '';
        }))
      ];
    };
}
