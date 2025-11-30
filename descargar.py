from roboflow import Roboflow

# Tu clave privada
rf = Roboflow(api_key="nBMPI8Q9dkew3mDfv8H3")

# Tu espacio de trabajo y proyecto (sacados de tu URL)
project = rf.workspace("transportesmart").project("minibuses-la-paz-benlc")

# Descargar la versión 2 en formato TFLite
version = project.version(2)

print("Iniciando descarga del modelo...")
version.download("tflite")
print("¡Descarga completa! Busca la carpeta nueva.")