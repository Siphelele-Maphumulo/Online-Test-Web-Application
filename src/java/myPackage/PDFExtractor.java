package myPackage;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.lang.reflect.Method;
import java.util.logging.Level;
import java.util.logging.Logger;

public class PDFExtractor {
    private static final Logger LOGGER = Logger.getLogger(PDFExtractor.class.getName());

    public static String extractCleanText(byte[] pdfBytes) {
        String rawText = "";
        PDDocument document = null;
        try {
            // Attempt to load PDF using reflection for cross-version compatibility (2.x vs 3.x)
            try {
                // PDFBox 2.x/3.x try load(byte[])
                Method m = PDDocument.class.getMethod("load", byte[].class);
                document = (PDDocument) m.invoke(null, pdfBytes);
            } catch (Exception ex) {
                // PDFBox 3.x specific fallback
                try {
                    Class<?> loaderClass = Class.forName("org.apache.pdfbox.Loader");
                    Method loadMethod = loaderClass.getMethod("loadPDF", byte[].class);
                    document = (PDDocument) loadMethod.invoke(null, pdfBytes);
                } catch (Exception ex2) {
                    // InputStream fallback
                    InputStream in = new ByteArrayInputStream(pdfBytes);
                    Method m = PDDocument.class.getMethod("load", InputStream.class);
                    document = (PDDocument) m.invoke(null, in);
                }
            }

            if (document != null) {
                PDFTextStripper stripper = new PDFTextStripper();
                stripper.setSortByPosition(true); // Preserve layout better for tables
                rawText = stripper.getText(document);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error extracting text from PDF", e);
        } finally {
            if (document != null) {
                try {
                    document.close();
                } catch (Exception e) {
                    // Ignore
                }
            }
        }

        return cleanText(rawText);
    }

    private static String cleanText(String text) {
        if (text == null) return "";
        
        return text
                // Remove headers/footers and common artifacts
                .replaceAll("(?i)Copyright reserved.*", "")
                .replaceAll("(?i)Please turn over", "")
                .replaceAll("(?m)^\\s*\\d+\\s*$", "") // Page numbers on their own lines
                
                // Remove tick symbols and mark indicators (common in marking guidelines)
                .replaceAll("||√|□|☑|☒", "")
                
                // Normalize spaces and newlines
                .replaceAll("\\s{2,}", " ")
                .replaceAll("\n{2,}", "\n")
                
                // Specific cleanup for financial numbers often separated by spaces
                // (e.g., "7 570 000" -> "7570000" might be risky, but common in accounting guidelines)
                // Actually, gpt-4o-mini is good at reading numbers with spaces. 
                // Let's keep them as is for now but ensure they aren't broken by newlines.
                
                .trim();
    }
}
