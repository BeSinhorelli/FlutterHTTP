import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

// Substitua esta chave pela sua do crudcrud.com
const String baseUrl =
    "https://crudcrud.com/api/0279ffe2485146b3aed450ec04745bd7";
const String resource = "/users";

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CRUD',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'CRUD App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => JanelaPrincipal();
}

// Serviço de API para crudcrud.com
class ApiService {
  static Future<List<dynamic>> fetchUsers() async {
    final url = Uri.parse('$baseUrl$resource');
    final response = await http.get(url);

    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data is List ? data : [];
    } else {
      throw Exception(
          'Falha ao carregar dados. Status: ${response.statusCode}');
    }
  }

  static Future<dynamic> getUser(String id) async {
    final url = Uri.parse('$baseUrl$resource/$id');
    final response = await http.get(url);

    print('GET User Status: ${response.statusCode}');
    print('GET User Response: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Falha ao carregar usuário. Status: ${response.statusCode}');
    }
  }

  static Future<void> createUser({
    required String nome,
    required String sobrenome,
    required String genero,
    required int idade,
    required String email,
  }) async {
    final url = Uri.parse('$baseUrl$resource');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'nome': nome,
        'sobrenome': sobrenome,
        'genero': genero,
        'idade': idade,
        'email': email
      }),
    );

    print('CREATE Status: ${response.statusCode}');
    print('CREATE Response: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception('Falha ao criar usuário. Status: ${response.statusCode}');
    }
  }

  static Future<void> deleteUser(String id) async {
    final url = Uri.parse('$baseUrl$resource/$id');
    final response = await http.delete(url);

    print('DELETE Status: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception(
          'Falha ao deletar usuário. Status: ${response.statusCode}');
    }
  }

  static Future<void> updateUser({
    required String id,
    required String nome,
    required String sobrenome,
    required String genero,
    required int idade,
    required String email,
  }) async {
    final url = Uri.parse('$baseUrl$resource/$id');
    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'nome': nome,
        'sobrenome': sobrenome,
        'genero': genero,
        'idade': idade,
        'email': email
      }),
    );

    print('UPDATE Status: ${response.statusCode}');
    print('UPDATE Response: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
          'Falha ao atualizar usuário. Status: ${response.statusCode}');
    }
  }
}

class JanelaPrincipal extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD com HTTP'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: ApiService.fetchUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Erro ao carregar dados',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.red),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("Nenhum usuário cadastrado"),
                      ],
                    ),
                  );
                } else {
                  final users = snapshot.data!;
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final String id = user['_id']?.toString() ?? '';
                      final String nome =
                          user['nome']?.toString() ?? 'Sem nome';
                      final String sobrenome =
                          user['sobrenome']?.toString() ?? '';
                      final String genero = user['genero']?.toString() ?? '';
                      final int idade = user['idade'] is int
                          ? user['idade']
                          : int.tryParse(user['idade']?.toString() ?? '') ?? 0;
                      final String email = user['email']?.toString() ?? '';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            child: Text(
                                nome.isNotEmpty ? nome[0].toUpperCase() : '?'),
                          ),
                          title: Text(
                            nome,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              if (sobrenome.isNotEmpty)
                                Text('Sobrenome: $sobrenome'),
                              if (genero.isNotEmpty) Text('Gênero: $genero'),
                              Text('Idade: $idade'),
                              if (email.isNotEmpty) Text('Email: $email'),
                            ],
                          ),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () async {
                                    final resultado = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            JanelaEditar(idPessoa: id),
                                      ),
                                    );
                                    if (resultado == 'atualizar') {
                                      setState(() {});
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteUser(context, id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const SegundaJanela(title: 'Novo Usuário'),
                  ),
                );
                if (resultado == 'atualizar') {
                  setState(() {});
                }
              },
              icon: const Icon(Icons.person_add),
              label: const Text("Adicionar usuário"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteUser(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: const Text('Tem certeza que deseja excluir este usuário?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await ApiService.deleteUser(id);
                  setState(() {});
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Usuário excluído com sucesso!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao excluir: $e')),
                    );
                  }
                }
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

class SegundaJanela extends StatefulWidget {
  const SegundaJanela({super.key, required this.title});

  final String title;

  @override
  State<SegundaJanela> createState() => JanelaDois();
}

class JanelaDois extends State<SegundaJanela> {
  final _formKey = GlobalKey<FormState>();

  String nome = "";
  String sobrenome = "";
  String genero = "";
  int idade = 0;
  String email = "";

  int groupRadio = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Usuário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite um nome';
                  }
                  return null;
                },
                onChanged: (value) => nome = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Sobrenome *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite um sobrenome';
                  }
                  return null;
                },
                onChanged: (value) => sobrenome = value,
              ),
              const SizedBox(height: 16),
              const Text('Gênero *',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      title: const Text("Feminino"),
                      value: 1,
                      groupValue: groupRadio,
                      onChanged: (int? value) {
                        setState(() {
                          genero = "Feminino";
                          groupRadio = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: const Text("Masculino"),
                      value: 2,
                      groupValue: groupRadio,
                      onChanged: (int? value) {
                        setState(() {
                          genero = "Masculino";
                          groupRadio = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Idade *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake),
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite uma idade';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor, digite uma idade válida';
                  }
                  final age = int.tryParse(value);
                  if (age != null && (age < 1 || age > 150)) {
                    return 'Por favor, digite uma idade entre 1 e 150';
                  }
                  return null;
                },
                onChanged: (value) => idade = int.tryParse(value) ?? 0,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite um email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Por favor, digite um email válido';
                  }
                  return null;
                },
                onChanged: (value) => email = value,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (genero.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Por favor, selecione um gênero')),
                      );
                      return;
                    }

                    try {
                      await ApiService.createUser(
                        nome: nome,
                        sobrenome: sobrenome,
                        genero: genero,
                        idade: idade,
                        email: email,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Usuário criado com sucesso!')),
                        );
                        Navigator.pop(context, 'atualizar');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao criar usuário: $e')),
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: const Text('Criar Usuário',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JanelaEditar extends StatefulWidget {
  const JanelaEditar({super.key, required this.idPessoa});

  final String idPessoa;

  @override
  State<JanelaEditar> createState() => JanelaEdicao();
}

class JanelaEdicao extends State<JanelaEditar> {
  final _formKey = GlobalKey<FormState>();

  String nome = "";
  String sobrenome = "";
  String genero = "";
  int idade = 0;
  String email = "";

  int groupRadio = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await ApiService.getUser(widget.idPessoa);
      setState(() {
        nome = userData['nome']?.toString() ?? '';
        sobrenome = userData['sobrenome']?.toString() ?? '';
        genero = userData['genero']?.toString() ?? '';
        idade = userData['idade'] is int
            ? userData['idade']
            : int.tryParse(userData['idade']?.toString() ?? '') ?? 0;
        email = userData['email']?.toString() ?? '';
        groupRadio = genero == "Feminino" ? 1 : 2;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar usuário: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Usuário'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: nome,
                      decoration: const InputDecoration(
                        labelText: 'Nome *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite um nome';
                        }
                        return null;
                      },
                      onChanged: (value) => nome = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: sobrenome,
                      decoration: const InputDecoration(
                        labelText: 'Sobrenome *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite um sobrenome';
                        }
                        return null;
                      },
                      onChanged: (value) => sobrenome = value,
                    ),
                    const SizedBox(height: 16),
                    const Text('Gênero *',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile(
                            title: const Text("Feminino"),
                            value: 1,
                            groupValue: groupRadio,
                            onChanged: (int? value) {
                              setState(() {
                                genero = "Feminino";
                                groupRadio = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile(
                            title: const Text("Masculino"),
                            value: 2,
                            groupValue: groupRadio,
                            onChanged: (int? value) {
                              setState(() {
                                genero = "Masculino";
                                groupRadio = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: idade.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Idade *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.cake),
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite uma idade';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Por favor, digite uma idade válida';
                        }
                        return null;
                      },
                      onChanged: (value) => idade = int.tryParse(value) ?? 0,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: email,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite um email';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Por favor, digite um email válido';
                        }
                        return null;
                      },
                      onChanged: (value) => email = value,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            await ApiService.updateUser(
                              id: widget.idPessoa,
                              nome: nome,
                              sobrenome: sobrenome,
                              genero: genero,
                              idade: idade,
                              email: email,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Usuário atualizado com sucesso!')),
                              );
                              Navigator.pop(context, 'atualizar');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Erro ao atualizar usuário: $e')),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('Atualizar Usuário',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
