import std.stdio;
import std.path;
import std.file;
import std.typecons;
import std.string;
import printed.canvas;

/// Creates a totaly new directory and returns the name
string resultDir()
{
	import std.random : Mt19937, unpredictableSeed;
	import std.conv : to;

	const Mt19937 gen = Mt19937(unpredictableSeed);
	string dir;

	do
		dir = "RESULT - " ~ to!string(gen.front);
	while (dir.exists);

	dir.mkdir();
	return dir;
}

alias ImageSize = Tuple!(float, float);
alias PdfSize = Tuple!(float, float);

/// Returns the image dimensions
ImageSize imageSize(Image image)
{
	return cast(ImageSize) tuple(image.printWidth, image.printHeight);
}

/// Returns the pdf dimensions
PdfSize pdfSize(PDFDocument pdf)
{
	return cast(PdfSize) tuple(pdf.pageWidth, pdf.pageHeight);
}

/// Returns the scaled dimensions of the given image actual size in function of the PDF dimensions
ImageSize scaling(ImageSize actualSize, PdfSize pdfSize)
{
	import std.algorithm.comparison : min;

	if (actualSize[0] <= pdfSize[0] && actualSize[1] <= pdfSize[1])
		return actualSize;

	const auto scale = min(pdfSize[0] / actualSize[0], pdfSize[1] / actualSize[1]);
	return cast(ImageSize) tuple(actualSize[0] * scale, actualSize[1] * scale);
}

/// Generate a PDF from the given image
void makePDF(const string imagePath, const string newFile, const string dir)
{
	import std.conv : to;

	auto pdf = new PDFDocument();
	auto img = new Image(imagePath);
	auto context = cast(IRenderingContext2D) pdf;
	const ImageSize imgSize = scaling(img.imageSize, pdf.pdfSize);

	context.drawImage(img, 0, 0, imgSize[0], imgSize[1]);
	std.file.write(dir ~ "/" ~ newFile, pdf.bytes);
}

void main(string[] args)
{
	if (args.length == 1)
		return;

	const string[] imageList = args[1 .. $];
	Tuple!(bool, string)[] handled;
	const string dir = resultDir();

	foreach (image; imageList)
	{
		writeln();
		writeln("Handling ", image);

		const string ext = image.extension.toLower();
		
		if (ext != ".png" && ext != ".jpg")
		{
			writeln("[ERROR]: Can't convert ", '"' ~ image ~ '"', " to PDF due to file format.");
			handled ~= tuple(false, image);
			continue;
		}

		const string originalName = image.baseName.stripExtension;
		const string newFile = originalName ~ ".pdf";
		writeln("Converting ", originalName, " to ", newFile);

		image.makePDF(newFile, dir);
		handled ~= tuple(true, image);
	}

	writeln("\nEnd of convertions.\n\nSummary:");
	int counter = 0;

	foreach (handle; handled)
		writeln(counter++, " | ", handle[0] ? "success" : "failed", " - \"", handle[1], "\"");
}
