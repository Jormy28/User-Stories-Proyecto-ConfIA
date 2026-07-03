Feature: EP01-Autenticación y Gestión de Usuarios
  Como usuario de ConfIA
  Quiero poder registrarme, iniciar sesión y gestionar mi perfil
  Para acceder de forma segura a mis análisis y referencias bibliográficas

  # User Story 01

  @AT-01 @US-01 @registro
  Scenario: Registro exitoso con datos válidos
    Given que un nuevo usuario accede al formulario de registro
    When completa todos los campos requeridos con datos válidos y una contraseña de al menos 8 caracteres
    Then el sistema crea la cuenta exitosamente
    And redirige al usuario al panel principal

  @AT-01 @US-01 @registro
  Scenario: El JWT generado al registrarse expira en 24 horas
    Given que un usuario completa el registro correctamente
    When el sistema genera el token de autenticación JWT
    Then el token tiene una vigencia máxima de 24 horas antes de expirar

  @AT-01 @US-01 @registro @negativo
  Scenario Outline: Registro rechazado por datos inválidos
    Given que un nuevo usuario completa el formulario de registro con correo "<correo>", contraseña "<password>" y nombre "<nombre>"
    When envía el formulario de registro
    Then el sistema rechaza el registro
    And muestra el mensaje de error "<mensaje_error>"

    Examples:
      | correo                | password   | nombre | mensaje_error                                   |
      | nuevo@upc.edu.pe       | 1234567    | Diego  | La contraseña debe tener al menos 8 caracteres  |
      | existente@upc.edu.pe   | Segura123  | Diego  | El correo ya está en uso                        |
      |                        | Segura123  | Diego  | El campo correo es obligatorio                  |
      | nuevo@upc.edu.pe       |            | Diego  | El campo contraseña es obligatorio              |
      | nuevo@upc.edu.pe       | Segura123  |        | El campo nombre es obligatorio                  |

  # User Story 02

  @AT-02 @US-02 @login
  Scenario: Inicio de sesión exitoso con credenciales correctas
    Given que un usuario registrado ingresa su correo y contraseña correctos en el formulario de inicio de sesión
    When envía las credenciales
    Then el sistema autentica al usuario
    And genera un JWT con vigencia de 24 horas
    And redirige al usuario al dashboard

  @AT-02 @US-02 @login
  Scenario: Sesión expirada tras 24 horas invalida el JWT
    Given que el JWT de un usuario ha expirado después de 24 horas
    When el usuario intenta realizar una operación autenticada
    Then el sistema retorna un error de autorización
    And solicita que el usuario inicie sesión nuevamente

  @AT-02 @US-02 @login @negativo
  Scenario Outline: Inicio de sesión rechazado por credenciales inválidas
    Given que un usuario ingresa el correo "<correo>" y la contraseña "<password>" en el formulario de inicio de sesión
    When envía las credenciales
    Then el sistema rechaza el acceso
    And muestra el mensaje "<mensaje_error>"

    Examples:
      | correo                  | password     | mensaje_error                                    |
      | registrado@upc.edu.pe   | Incorrecta1  | Credenciales inválidas                           |
      | registrado@upc.edu.pe   | 1234567      | La contraseña debe tener al menos 8 caracteres   |
      | noexiste@upc.edu.pe     | Segura123    | Credenciales inválidas                           |

  # User Story 03

  @AT-03 @US-03 @perfil
  Scenario: Visualización correcta de datos del perfil
    Given que un usuario autenticado accede a la pantalla de perfil
    When la vista se carga correctamente
    Then el sistema muestra su nombre, carrera y ciclo actual almacenados en la base de datos

  @AT-03 @US-03 @perfil
  Scenario Outline: Actualización de perfil exitosa con datos válidos
    Given que un usuario autenticado edita su "<campo>" a "<nuevo_valor>" en el formulario de perfil
    When guarda los cambios
    Then el sistema persiste la actualización en la base de datos de forma inmediata
    And refleja los nuevos datos en la interfaz sin recargar la página
    And muestra una notificación de éxito al usuario

    Examples:
      | campo   | nuevo_valor             |
      | nombre  | Andrea Torres           |
      | carrera | Ingeniería de Software  |
      | ciclo   | 8                       |

  @AT-03 @US-03 @perfil @negativo
  Scenario Outline: Guardado de perfil rechazado por datos inválidos
    Given que un usuario autenticado intenta guardar su perfil con "<campo>" igual a "<valor>"
    When confirma la acción de guardado
    Then el sistema rechaza el guardado
    And muestra el mensaje de error "<mensaje_error>"

    Examples:
      | campo   | valor                 | mensaje_error                    |
      | nombre  |                       | El campo nombre es obligatorio   |
      | correo  | existente@upc.edu.pe  | El correo ya está en uso         |

