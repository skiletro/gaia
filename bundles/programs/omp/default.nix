{
  inputs,
  lib,
  ...
}: {
  home-manager = {config, ...}: let
    colors = config.lib.stylix.colors.withHashtag;
    theme = {
      name = "stylix";
      colors = with colors; {
        accent = base0D;
        border = base02;
        borderAccent = base0D;
        borderMuted = base03;
        success = base0B;
        error = base08;
        warning = base0A;
        muted = base04;
        dim = base03;
        text = base05;
        thinkingText = base04;
        selectedBg = base02;
        userMessageBg = base01;
        customMessageBg = base01;
        toolPendingBg = base01;
        toolSuccessBg = base01;
        toolErrorBg = base01;
        statusLineBg = base00;
        userMessageText = base05;
        customMessageText = base05;
        customMessageLabel = base0D;
        toolTitle = base05;
        toolOutput = base04;
        mdHeading = base0D;
        mdLink = base0C;
        mdLinkUrl = base04;
        mdCode = base0B;
        mdCodeBlock = base05;
        mdCodeBlockBorder = base02;
        mdQuote = base04;
        mdQuoteBorder = base03;
        mdHr = base03;
        mdListBullet = base0D;
        toolDiffAdded = base0B;
        toolDiffRemoved = base08;
        toolDiffContext = base04;
        syntaxComment = base03;
        syntaxKeyword = base0E;
        syntaxFunction = base0D;
        syntaxVariable = base05;
        syntaxString = base0B;
        syntaxNumber = base09;
        syntaxType = base0C;
        syntaxOperator = base0F;
        syntaxPunctuation = base04;
        thinkingOff = base03;
        thinkingMinimal = base04;
        thinkingLow = base0C;
        thinkingMedium = base0D;
        thinkingHigh = base0E;
        thinkingXhigh = base0F;
        thinkingMax = base08;
        bashMode = base0C;
        pythonMode = base0E;
        statusLineSep = base03;
        statusLineModel = base0E;
        statusLinePath = base0D;
        statusLineGitClean = base0B;
        statusLineGitDirty = base0A;
        statusLineContext = base0C;
        statusLineSpend = base0D;
        statusLineStaged = base0B;
        statusLineDirty = base0A;
        statusLineUntracked = base08;
        statusLineOutput = base05;
        statusLineCost = base09;
        statusLineSubagents = base0E;
      };
    };
  in {
    imports = [inputs.omp.homeManagerModules.default];

    programs.omp.enable = true;
    home.file.".omp/agent/themes/stylix.json".text = lib.generators.toJSON {} theme;
  };
}
