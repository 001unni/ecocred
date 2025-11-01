from PIL import Image
import google.generativeai as genai
import re

# ✅ Configure API Key
genai.configure(api_key="AIzaSyDM8jCJogG4vlFfTThmM7UaT98m0gMI3ik")

def generate_text(image_path):
    model = genai.GenerativeModel('gemini-2.5-pro')
    img = Image.open(image_path)

    # 🔹 Improved prompt (short but powerful)
    prompt = """
    Identify the eco-friendly activity or content in this image 
    (tree planting, waste management, energy saving, carpooling, eco shopping, electricity bill, etc.).
    If it is an electricity bill, extract or estimate the total bill amount.
    """

    response = model.generate_content([prompt, img])
    text = response.text.strip()
    print("🔹 Raw Gemini Response:\n", text)

    # --- Extract logic ---
    # Detect activity
    activity_match = re.search(
        r'(tree planting|waste management|energy saving|carpooling|eco shopping|electricity bill)',
        text,
        re.IGNORECASE,
    )
    activity = activity_match.group(1).title() if activity_match else "Unknown"

    # Detect amount if any
    amount_match = re.search(r'(\d{2,5})', text)
    amount = int(amount_match.group(1)) if amount_match else 0

    # --- Decide points ---
    points = 0
    if activity == "Electricity Bill":
        if amount > 0:
            if amount <= 500:
                points = 100
            elif amount <= 1000:
                points = 50
            elif amount <= 5000:
                points = 20
            else:
                points = 0
        else:
            points = 150
    elif activity == "Tree Planting":
        points = 300
    elif activity == "Waste Management":
        points = 200
    elif activity == "Energy Saving":
        points = 150
    elif activity == "Carpooling":
        points = 250
    elif activity == "Eco Shopping":
        points = 180
    else:
        points = 100

    print("\n✅ Extracted Results:")
    print(f"Activity: {activity}")
    if activity == "Electricity Bill":
        print(f"Bill Amount: ₹{amount}")
    print(f"Points: {points}")

    return {"activity": activity, "amount": amount, "points": points}



# 🌱 Example usage
if __name__ == "__main__":
    image_path = r"C:\Users\user\PycharmProjects\Eco_Frnd\myapp\bill1.jpg"
    result = generate_text(image_path)
    print("\n🎯 Final Result:", result)
    a=result['points']
    print("points",a)
