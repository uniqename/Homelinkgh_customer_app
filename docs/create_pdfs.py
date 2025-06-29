#!/usr/bin/env python3
"""
Convert text documentation to PDF format for App Store Connect submission
"""

import os
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch

def text_to_pdf(input_file, output_file, title):
    """Convert a text file to PDF with proper formatting"""
    doc = SimpleDocTemplate(output_file, pagesize=letter)
    styles = getSampleStyleSheet()
    
    # Custom styles
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=16,
        spaceAfter=30,
        textColor='darkblue'
    )
    
    normal_style = ParagraphStyle(
        'CustomNormal',
        parent=styles['Normal'],
        fontSize=10,
        leading=12,
        spaceAfter=6
    )
    
    story = []
    
    # Add title
    story.append(Paragraph(title, title_style))
    story.append(Spacer(1, 12))
    
    # Read and format content
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()
        
    # Split into paragraphs and format
    paragraphs = content.split('\n\n')
    for para in paragraphs:
        if para.strip():
            # Clean up the text for PDF
            clean_para = para.replace('\n', ' ').strip()
            story.append(Paragraph(clean_para, normal_style))
            story.append(Spacer(1, 6))
    
    doc.build(story)
    print(f"Created PDF: {output_file}")

def main():
    """Create PDF versions of all documentation"""
    docs_dir = "/Users/enamegyir/Documents/Projects/blazer_home_services_app/customer_app/docs"
    
    # Files to convert
    files_to_convert = [
        ("app_store_review_information.txt", "App Store Review Information", "HomeLinkGH_Review_Information.pdf"),
        ("demo_accounts.txt", "Demo Accounts for Testing", "HomeLinkGH_Demo_Accounts.pdf"),
        ("app_features_overview.txt", "App Features Overview", "HomeLinkGH_Features_Overview.pdf"),
        ("app_store_metadata.md", "App Store Metadata", "HomeLinkGH_App_Store_Metadata.pdf"),
        ("security_guide.md", "Security Guide", "HomeLinkGH_Security_Guide.pdf")
    ]
    
    for input_file, title, output_file in files_to_convert:
        input_path = os.path.join(docs_dir, input_file)
        output_path = os.path.join(docs_dir, output_file)
        
        if os.path.exists(input_path):
            try:
                text_to_pdf(input_path, output_path, title)
            except Exception as e:
                print(f"Error converting {input_file}: {e}")
        else:
            print(f"File not found: {input_path}")

if __name__ == "__main__":
    main()