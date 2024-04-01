import requests
import pandas as pd

url = "https://api.hiboo.io/v2/fleet/equipments/history"
headers = {
    "x-access-token": "Mon-TOKEN"
}


limite_par_page = 50
offset = 0


pages_dataframes = []

while True:
    params = {
        "limit": limite_par_page,
        "offset": offset
    }

    response = requests.get(url, headers=headers, params=params)

    if response.status_code == 200:
        json_data = response.json()["data"]["rows"]

        
        if not json_data:
            break

        df = pd.DataFrame(json_data)
        print(f"DataFrame pour la page {offset // limite_par_page + 1}:")
        print(df)

       
        pages_dataframes.append(df)

        offset += limite_par_page
    else:
        print(f"Erreur {response.status_code} : {response.text}")
        break


resultat_final = pd.concat(pages_dataframes, ignore_index=True)


excel_file = "donnees_hiboo_final.xlsx"
resultat_final.to_excel(excel_file, index=False)

print(f"Données exportées avec succès vers {excel_file}")
