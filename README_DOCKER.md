# FacturadorPro5 - Docker Setup

Guía rápida para ejecutar el proyecto en **cualquier PC** usando Docker.

---

## 📋 Requisitos Previos

**En la PC donde se ejecutará:**

1. **Docker Desktop** instalado:
   - Windows/Mac: https://www.docker.com/products/docker-desktop
   - Linux: `sudo apt install docker.io docker-compose`

2. **Verificar instalación:**
   ```bash
   docker --version
   docker-compose --version
   ```

---

## 🚀 Pasos de Instalación

### 1. Copiar el Proyecto
Copia toda la carpeta `facturadorpro5` a la PC de pruebas.

### 2. Configurar `.env`
```bash
# Copiar template Docker
cp .env.docker .env
```
**⚠️ IMPORTANTE:**
- El archivo `.env.docker` ya tiene la configuración correcta: `DB_HOST=mysql` y usuario `facturador`.
- La URL base está configurada como `facturadorpro5.test`. **No la cambies**.

### 3. Configurar DNS Local (Hosts)
Para que Windows reconozca `facturadorpro5.test`:

1. Abre el **Bloc de Notas** como Administrador.
2. Abre el archivo: `C:\Windows\System32\drivers\etc\hosts`
3. Agrega al final esta línea:
   ```text
   127.0.0.1 facturadorpro5.test
   ```
4. Guarda el archivo.

### 4. Levantar Contenedores
```bash
# En la carpeta del proyecto
docker-compose up -d
```
**Nota:** La primera vez descargará imágenes (5-10 min).

### 5. Preparar Carpetas (Evitar error Symlink)
**Antes de seguir**, ve a la carpeta `public` en tu explorador de archivos de Windows y **borra** la carpeta o archivo llamado `storage`.
*(Si no lo borras, el paso siguiente fallará)*.

### 6. Ejecutar Migraciones
Ejecuta estos bloque de comandos en tu terminal para configurar el sistema:

```bash
# Entrar al contenedor
docker exec -it facturadorpro5_app bash

# --- EJECUTAR DENTRO DEL CONTENEDOR ---

# 1. Instalar Tablas
php artisan migrate --database=system
php artisan db:seed --database=system

# 2. Crear enlace de imágenes (Si falla, revisa el paso 5)
php artisan storage:link

# 3. Limpiar caché (Obligatorio)
php artisan config:clear

# 4. Salir
exit
```

### 7. Acceder al Sistema
Abre el navegador e ingresa a:
```
[http://facturadorpro5.test](http://facturadorpro5.test)
```
*Credenciales por defecto: admin@gmail.com / 123456*

---

## 🛠️ Comandos Útiles

### Ver logs en tiempo real
```bash
docker-compose logs -f app
```

### Reiniciar servicios
```bash
docker-compose restart
```

### Detener todo
```bash
docker-compose down
```

### Acceder a MySQL
```bash
docker exec -it facturadorpro5_mysql mysql -u facturador -pfacturador123 tenancy
```

---

## 🐛 Solución de Errores Comunes

### Error 500 al buscar RUC/DNI
Falta el token de API Perú en la base de datos.
**Solución:** Ejecuta este comando SQL directo en tu terminal (reemplaza TU_TOKEN):

```bash
docker exec -it facturadorpro5_mysql mysql -u facturador -pfacturador123 tenancy -e "UPDATE configurations SET token_apiruc='TU_TOKEN_AQUI' WHERE id=1;"
```

### Error "Symlink: No such file or directory"
Docker no puede sobrescribir la carpeta `public/storage` creada por Windows.
**Solución:** Borra manualmente la carpeta `storage` dentro de `public` en Windows y ejecuta `php artisan storage:link` de nuevo.

### Error "Database [tenant] not configured"
El sistema no reconoce la URL.
**Solución:** Asegúrate de estar entrando por `http://facturadorpro5.test` y NO por `localhost`. Revisa que hiciste el **Paso 3 (Hosts)**.