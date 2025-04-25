from behave import *

import os
import tempfile
import subprocess

from datetime import datetime

def assert_equal(a, b):
    if a != b:
        raise AssertionError(f'{str(a)} != {str(b)}')

def assert_contains(container, item):
    if item not in container:
        raise AssertionError(f'{str(item)} is not in {container}')

@given('a git repo {repo}')
def step_impl(context, repo):
    if not hasattr(context, 'repos'):
        context.repos = {}
    context.repos[repo] = tempfile.TemporaryDirectory()
    cwd = context.repos[repo].name
    subprocess.check_output(['git', 'init'], cwd=cwd)
    subprocess.check_output(['git', 'commit', '--allow-empty', '-m', 'Initial commit'], cwd=cwd)
    subprocess.check_output(['git', 'checkout', '-b', 'tmp'], cwd=cwd)

@given('we have cloned {repo} to {clone}')
def step_impl(context, repo, clone):
    context.repos[clone] = tempfile.TemporaryDirectory()
    cwd = context.repos[clone].name
    subprocess.check_output(['git', 'clone', context.repos[repo].name, '-b', 'master', '.'], cwd=cwd)

@given('{repo} has initialised git-lock')
def step_impl(context, repo):
    cwd = context.repos[repo].name
    subprocess.check_output(['git', 'lock', 'show'], cwd=cwd)

@given('{repo} is configured with {option} {value}')
def step_impl(context, repo, option, value):
    cwd = context.repos[repo].name
    subprocess.check_output(['git', 'config', option, value], cwd=context.repos[repo].name)

@given('we create file {path} in {repo}')
def step_impl(context, path, repo):
    cwd = context.repos[repo].name
    subprocess.check_output(['touch', path], cwd=cwd)

@given('we push {repo}')
def step_impl(context, repo):
    cwd = context.repos[repo].name
    subprocess.check_output(['git', 'push'], cwd=cwd)

@given('we add file {path} in {repo}')
@when('we add file {path} in {repo}')
def step_impl(context, path, repo):
    cwd = context.repos[repo].name
    subprocess.check_output(['git', 'add', path], cwd=cwd)

@given('we commit {repo}')
@when('we commit {repo}')
def step_impl(context, repo):
    cwd = context.repos[repo].name
    subprocess.check_output(['git', 'commit', '-m', 'commit'], cwd=cwd)

@when('we modify file {path} in {repo}')
def step_impl(context, path, repo):
    cwd = context.repos[repo].name
    with open(os.path.join(cwd, path), 'w') as f:
        subprocess.run(['echo', 'modification'], cwd=cwd, stdout=f)

@when('we lock {repo} {path}')
def step_impl(context, repo, path):
    cwd = context.repos[repo].name
    subprocess.check_output(['git', 'lock', 'acquire', path], cwd=cwd)

@when('we release {repo} {path}')
def step_impl(context, repo, path):
    cwd = context.repos[repo].name
    subprocess.check_output(['git', 'lock', 'release', path], cwd=cwd)

@then('{repo} can lock {path}')
def step_impl(context, repo, path):
    cwd = context.repos[repo].name
    subprocess.check_output(['git', 'lock', 'acquire', path], cwd=cwd)

@then('{repo} cannot lock {path}')
def step_impl(context, repo, path):
    cwd = context.repos[repo].name
    assert subprocess.run(['git', 'lock', 'acquire', path], cwd=cwd).returncode != 0

@then('{repo} {path} check succeeds')
def step_impl(context, path, repo):
    cwd = context.repos[repo].name
    subprocess.check_output(['git', 'lock', 'check', path], cwd=cwd)

@then('{repo} {path} check fails')
def step_impl(context, path, repo):
    cwd = context.repos[repo].name
    assert subprocess.run(['git', 'lock', 'check', path], cwd=cwd).returncode != 0

@then('{repo} git-lock show contains {expected}')
def step_impl(context, repo, expected):
    cwd = context.repos[repo].name
    p = subprocess.run(['git', 'lock', 'show'], cwd=cwd, stdout=subprocess.PIPE, encoding='utf-8')
    lines = p.stdout.strip().split('\n')
    assert_contains(lines, expected)

@then('{repo} git-lock show does not contain {expected}')
def step_impl(context, repo, expected):
    cwd = context.repos[repo].name
    p = subprocess.run(['git', 'lock', 'show'], cwd=cwd, stdout=subprocess.PIPE, encoding='utf-8')
    lines = p.stdout.strip().split('\n')
    assert expected not in lines

@then('{repo} {path} is not locked')
def step_impl(context, path, repo):
    cwd = context.repos[repo].name
    p = subprocess.run(['git', 'lock', 'owner', path], cwd=cwd, stdout=subprocess.PIPE, encoding='utf-8')
    assert_equal(p.stdout.strip(), '')

@then('{repo} {path} is locked by {name}')
def step_impl(context, path, repo, name):
    cwd = context.repos[repo].name
    p = subprocess.run(['git', 'lock', 'owner', path], cwd=cwd, stdout=subprocess.PIPE, encoding='utf-8')
    assert_equal(p.stdout.strip(), name)

@then('{repo} commit fails')
def step_impl(context, repo):
    cwd = context.repos[repo].name
    assert subprocess.run(['git', 'commit', '-m', 'commit'], cwd=cwd).returncode != 0

@then('{repo} commit delays')
def step_impl(context, repo):
    cwd = context.repos[repo].name
    start = datetime.now()
    subprocess.check_output(['git', 'commit', '-m', 'commit'], cwd=cwd)
    assert (datetime.now() - start).seconds >= 5

@then('{repo} push fails')
def step_impl(context, repo):
    cwd = context.repos[repo].name
    assert subprocess.run(['git', 'push'], cwd=cwd).returncode != 0

@then('{repo} push delays')
def step_impl(context, repo):
    cwd = context.repos[repo].name
    start = datetime.now()
    subprocess.check_output(['git', 'push'], cwd=cwd)
    assert (datetime.now() - start).seconds >= 5
