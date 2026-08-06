{
  pkgs,
  ...
}:
{

  packages =
    with pkgs;
    [
      beets.override
      {
        pluginOverrides = {
          beetcamp = {
            enable = true;
            propagatedBuildInputs = [ beetcamp ];
          };
          beets-filetote = {
            enable = true;
            propagatedBuildInputs = [ beets-filetote ];
          };
        };
      }
      ffmpeg
      yt-dlp
    ]
    ++ (with pkgs.python314Packages; [
      beetcamp
      beets-filetote
    ]);

}
