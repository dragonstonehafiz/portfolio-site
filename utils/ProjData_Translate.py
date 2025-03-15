from utils.ProjectObject import ProjectObject
from datetime import date

makeine_vol1ep1 = ProjectObject(
    title='Too Many Losing Heroines!!! Drama CD Vol. 1 "I\'ll Teach You The Secret To Style"',
    description="""
    As a fan of *Too Many Losing Heroines!!!*, I found myself wanting more content after finishing all the available light novels. 
    During my search, I discovered that the limited-edition Blu-rays included exclusive drama CDs featuring original stories.  

    Since my Japanese listening skills weren’t very strong, I initially set out to transcribe the audio as a way to improve. 
    However, as I worked through the dialogues, I realized that no one had made this content available on YouTube. 
    Seeing an opportunity to contribute to the fan community, I decided to take on the challenge of translating and subtitling the drama CD myself.
    """,
    vid_link="https://youtu.be/gRx0sX_9PyA?si=EAmbJ3nRvHAEaBqd",
    date_=date(year=2025, month=2, day=23),
    what_i_did=["**Synchronized subtitles with the Japanese audio** to ensure smooth and natural readability.",
                "**Accurately transcribed spoken dialogue** to create a reliable foundation for translation.",
                '**Adapted the script into English** while maintaining the original tone, character personalities, and nuances.'],
    tags=["anime"],
    project_type="Too Many Losing Heroines!!!")


makeine_vol1ep2 = ProjectObject(
    title='Too Many Losing Heroines!!! Drama CD Vol. 1 "Be careful with sneak photography."',
    description="""
    After translating the first story from *Too Many Losing Heroines!!!* Drama CD Vol. 1, I wanted to continue with the second.  
    Like before, this drama CD was an exclusive Blu-ray bonus, meaning it wasn’t widely available to fans.  

    This story introduces a **much more neurotic character** who **stutters frequently due to nervousness**,  
    making transcription and translation more challenging than in the first episode.
    Capturing these speech patterns accurately while ensuring smooth readability in English was a delicate balance.  

    To assist with this translation, I built a **[custom translation helper app](https://github.com/dragonstonehafiz/translator-helper)** using the **OpenAI API**,  
    which helped generate alternative phrasings and refine difficult sections.  
    Additionally, I used **OpenAI Whisper** to aid with transcription, particularly for the stuttered lines  
    that were difficult to parse by ear alone.
    """,
    vid_link="https://youtu.be/mABaX-7lhk0",
    date_=date(year=2025, month=3, day=15),
    what_i_did=[
        "**Transcribed Japanese dialogue** with extra attention to stutters and speech quirks, preserving the character’s neurotic tendencies.",
        "**Adapted the script into English**, balancing natural readability with maintaining the character’s nervous tone.",
        "**Developed an translator/transcription tool**, improving accuracy for difficult-to-hear segments."
    ],
    tags=["anime"],
    project_type="Too Many Losing Heroines!!!"
)
