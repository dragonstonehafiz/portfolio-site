from utils.ProjectObject import ProjectObject
from datetime import date

BudgetingSpreadsheet = ProjectObject(
    title="Budgeting Spreadsheet Automation",
    description="""
    A Python-based tool that automates the setup of budgeting spreadsheets by inserting formulas and formatting new sheets each year. 
    The program ensures consistent calculations and improves readability with automated conditional formatting.
    """,
    date_=date(year=2024, month=1, day=16),
    what_i_did=[
        "Developed a Python script to automate spreadsheet formula insertion, **reducing manual effort** and **improving consistency** in yearly budget tracking.",
        "Built a simple **Tkinter-based GUI** to enhance usability, enabling efficient spreadsheet updates without manual coding."],
    img_paths=[
        "images/other/spreadsheet1.png",
        "images/other/spreadsheet2.png",
        "images/other/spreadsheet3.png",
        "images/other/spreadsheet4.png"],
    tags=["python"])

YouTubeCommentAnalyzer = ProjectObject(
    title="YouTube Comment Keyword Search",
    description="""
    I started this project because I have a small YouTube channel that I run as a hobby and wanted to find out what people were saying about my videos. 
    I also wanted to take a crack at doing **sentiment analysis** just to see how it worked. 
    Using [YouTube Data API](https://developers.google.com/youtube/v3), I extracted video and comment data from my channel which I then used to perform sentiment analysis. 
    Using the generated sentiment scores, I generated multiple Word Clouds to visualize the most frequently appearing words on negative and positive comments.
    
    In the end, I wasn't able to learn anything I didn't already know from the word clouds, but it was a fun project nevertheless.

    Everything in this project was written in `Python`. 
    Libraries like `pandas`, `matplotlib`, `wordcloud`, `spacy`, and `sklearn` were used to help with data manipulation and visualization.
    """,
    date_=date(year=2024, month=8, day=6),
    what_i_did=[
        "Extracted and processed YouTube video and comment data **using the YouTube Data API** for sentiment analysis.",
        "Implemented **sentiment classification using a pretrained RoBERTa model**, achieving high-accuracy results.",
        "Developed word **cloud visualizations with matplotlib** and wordcloud, revealing key discussion trends."],
    img_paths=[
        "images/other/youtube1.png",
        "images/other/youtube2.png",
        "images/other/youtube3.png",
        "images/other/youtube4.png",
        "images/other/youtube5.png",
        "images/other/youtube6.png"],
    tags=["python", "api", 'ai'])

DiamondCityRadio = ProjectObject(
    title="Diamond City Radio (Fallout-Inspired Music Player)",
    description="""
    A Java-based music player inspired by Fallout 4’s Diamond City Radio. 
    The app plays a mix of music tracks and voice clips, dynamically interweaving DJ commentary between songs to simulate an in-game radio experience.
    """,
    date_=date(year=2024, month=4, day=27),
    vid_link="https://youtu.be/E9zW9e6HOzU",
    what_i_did=[
        "Implemented an **optimized file-loading system** for music and voice lines, reducing load times and ensuring seamless playback.",
        "Integrated Box2D for **accurate entity collision detection**, improving UI responsiveness.",
        "Developed logic for **dynamic voice line selection**, enhancing game immersion with contextual dialogue."],
    tags=["java", "libgdx"])

TranslatorHelper = ProjectObject(
    title="Translator Helper",
    description="""
    A little hobby of mine is **transcribing and translating anime drama CDs**. 
    While I am generally able to do so on my own with some difficulty, there are times where I am unable to figure out what a character is saying, or how exactly I should translate a particular phrase.
    
    As such, I quickly put together an app to help me with the process.
    """,
    github_link="https://github.com/dragonstonehafiz/translator-helper",
    date_=date(year=2025, month=3, day=9),
    what_i_did=[
        "Developed an **interactive UI** using **Streamlit**, making the tool accessible for manual translation assistance.",
        "Implemented **OpenAI Whisper-based transcription**, improving accuracy for difficult-to-hear dialogue.",
        "Integrated **GPT-4o** to provide multiple translation suggestions for refining phrasing.",
        "Added a **grading system** to assess translation quality based on fluency and accuracy."
        ],
    vid_link="https://youtu.be/8eeY0Wq4U7I",
    img_paths=[
        "images/other/TranslatorHelper1.png",
        "images/other/TranslatorHelper2.png",
        "images/other/TranslatorHelper3.png",
        ],
    tags=["python", "api", "ai", "anime"])
