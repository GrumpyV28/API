import requests 
import pandas as pd

url = "https://api.hiboo.io/v2/fleet/equipments/history"
headers = {
    "x-access-token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NTIwNTIxLCJ3b3Jrc3BhY2VJZCI6MTUwLCJhZG1pbiI6dHJ1ZSwiYWRtaW5PZk9yZ2FuaXphdGlvbiI6dHJ1ZSwib3JnYW5pemF0aW9uSWQiOjU0LCJvcmdhbml6YXRpb25QbGFuIjoiZW50ZXJwcmlzZSIsImlhdCI6MTcwNTM5ODAwNywiZXhwIjoxNzA2MjYyMDA3fQ.k1kSkdfolTG4p1dRkgQQFpVOf3be57qrj6yJwfrLYdU"
}

params = {
    "limit": 100,  
    "offset": 0
}

response = requests.get(url, headers=headers, params=params)

if response.status_code == 200:
    json_data = response.json()["data"]["rows"]
    
    df = pd.DataFrame(json_data)
    print("DataFrame complet:")
    print(df)
    
    print("\nInformations sur le DataFrame:")
    print(df.info())
    
    print("\nRéponse JSON de l'API :")
    print(json_data)
        
    excel_file = "donnees_hiboo.xlsx"
    df.to_excel(excel_file , index=False)
    
    print(f"Données exportées avec succès vers {excel_file}")
else:
    print(f"Erreur {response.status_code}: {response.text}")
