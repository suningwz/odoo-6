# Part of Odoo. See LICENSE file for full copyright and licensing details.
{
    'name': 'Odoo session timeout',
    'version': '1.0',
    'category': 'Tools',
    'description': """
        Auto logout if user don't have any activity on opened tab
    """,
    'depends' : ['web'],
    'demo': [],
    'data': [
        'views/template.xml',
    ],
}
