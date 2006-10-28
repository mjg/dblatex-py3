import sys
import os
import re

#
# Objects to convert an image format to another. Actually use the underlying
# tools.
#
class ImageConverter:
    def __init__(self):
        self.debug = 1
        self.fake = 0

    def system(self, cmd, doexec=1):
        if not(cmd):
            return ""
        if self.debug:
            print cmd
        if doexec:
            if not(self.fake):
                os.system(cmd)
        else:
            return cmd

    def convert(self, input, output, format, doexec=1):
        pass


class GifConverter(ImageConverter):
    def convert(self, input, output, format, doexec=1):
        cmd = "convert \"%s\" %s" % (input, output)
        return self.system(cmd, doexec)

class EpsConverter(ImageConverter):
    def convert(self, input, output, format, doexec=1):
        if format == "pdf":
            cmd = "epstopdf --outfile=%s \"%s\"" % (output, input)
        elif format == "png":
            cmd = "convert \"%s\" %s" % (input, output)
        else:
            cmd = ""
        return self.system(cmd, doexec)

class FigConverter(ImageConverter):
    def convert(self, input, output, format, doexec=1):
        if (format != "eps"):
            conv = EpsConverter()
            conv.fake = self.fake
            conv.debug = self.debug
            epsfile = "tmp_fig.eps"
            post = " && "
            post += conv.convert(epsfile, output, format, doexec=0)
        else:
            post = ""
            epsfile = output

        cmd = "fig2dev -L eps \"%s\" > %s" % (input, epsfile)
        cmd += post
        self.system(cmd)


#
# The Imagedata class handles all the image transformation
# process, from the discovery of the actual image involved to
# the conversion process.
#
class Imagedata:
    def __init__(self):
        self.paths = []
        self.input_format = "png"
        self.output_format = "pdf"
        self.converted = {}

    def convert(self, fig):
        # First, scan the available formats
        (realfig, ext) = self.scanformat(fig)

        # No real file found, give up
        if not(realfig):
            print "Image '%s' not found" % fig
            return fig

        # Check if this image has been already converted
        if self.converted.has_key(realfig):
            print "Image '%s' already converted as %s" % \
                  (fig, self.converted[realfig])
            return self.converted[realfig]

        # No format found, take the default one
        if not(ext):
            ext = self.input_format

        # Natively supported format?
        if (ext == self.output_format):
            return fig

        # Try to convert
        count = len(self.converted)
        newfig = "fig%d.%s" % (count, self.output_format)

        if (ext == "fig" and self.output_format in ("eps", "pdf", "png")):
            conv = FigConverter()
        elif (ext == "eps"):
            conv = EpsConverter()
        elif (ext in ("gif", "bmp")):
            conv = GifConverter()
        else:
            # Unknown conversion to do, or nothing to do
            return fig

        # Convert the image and put it in the cache
        conv.convert(realfig, newfig, self.output_format)
        self.converted[realfig] = newfig
        return newfig

    def scanformat(self, fig):
        (root, ext) = os.path.splitext(fig)

        if (ext):
            realfig = self.find(fig)
            return (realfig, ext[1:])
        
        # Lookup for the best suited available figure
        if (self.output_format == "pdf"):
            formats = ("png", "pdf", "jpg", "eps", "gif", "fig")
        else:
            formats = ("eps", "fig", "pdf", "png")

        for format in formats:
            realfig = self.find("%s.%s" % (fig, format))
            if realfig:
                print "Found %s for '%s'" % (format, fig)
                break

        # Maybe a figure with no extension
        if not(realfig):
            realfig = self.find(fig)
            format = ""

        return (realfig, format)
        
    def find(self, fig):
        # First, the obvious absolute path case
        if os.path.isabs(fig):
            if os.path.isfile(fig):
                return fig
            else:
                return None

        # Then, look for the file in known paths
        for path in self.paths:
            realfig = os.path.join(path, fig)
            if os.path.isfile(realfig):
                return realfig

        return None
       
    def system(self, cmd):
        print cmd
        rc = os.system(cmd)
        # TODO: raise error when system call failed

